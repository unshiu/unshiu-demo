# == Schema Information
#
# Table name: tpc_topic_cmm_communities
#
#  id               :integer(4)      not null, primary key
#  tpc_topic_id     :integer(4)      not null
#  cmm_community_id :integer(4)      not null
#  public_level     :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#

module TpcTopicCmmCommunityModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        acts_as_unshiu_tpc_relation
        acts_as_cached
        
        acts_as_searchable :searchable_fields => [],
                           :attributes => {:public_level => :public_level, :updated_at => :updated_at, :cmm_community_id => :cmm_community_id}

        belongs_to :tpc_topic, :dependent => :destroy
        belongs_to :cmm_community

        before_destroy :expire_portal_cache

        alias_method_chain :document_object, :include
      end
    end
  end
  
  module ClassMethods
    
    # クエリキャッシュの生存時間
    def ttl
      AppResources[:tpc][:tpc_topic_cmm_community_cache_time]
    end
    
    # 「全体に公開」のトピック
    def public_topics(options = {})
      options.merge!({:conditions => ["public_level = ?", TpcRelationSystem::PUBLIC_LEVEL_ALL], :order => 'created_at desc'})
      self.find(:all, options)
    end
  
    # ポータル用にトピック一覧を返す
    # 対象は全体公開のトピックのみである。内容はキャッシュされており、一定期間経つか、該当トピックの一つが削除されるまで同じものがかえされる
    # return:: トピック一覧
    def cache_portal_topics
      TpcTopicCmmCommunity.get_cache("TpcTopicCmmCommunity#portal_topics") do
        find(:all, :conditions => [' public_level = ? ', TpcRelationSystem::PUBLIC_LEVEL_ALL], 
             :limit => AppResources[:tpc][:portal_tpc_cmm_latest_topic_size], :order => 'created_at desc' )
      end
    end
    
    # community_idのコミュニティのトピックの一覧を取り出す 
    def find_by_community_id_and_max_public_level(community_id, max_level, options = {})
      options.merge!({:include => [:tpc_topic], :conditions => ["cmm_community_id = ? and public_level <= ? and tpc_topics.deleted_at is null", community_id, max_level]})
      TpcTopicCmmCommunity.find(:all, options)
    end

    # あるコミュニティのトピックをキーワード検索
    def keyword_search_by_community_id_and_max_public_level(community_id, max_public_level, keyword, options = {})
      keyword = '' unless keyword
        
      options.merge!({:attributes => ["cmm_community_id NUMEQ #{community_id}", "public_level NUMLE #{max_public_level}"],
        :order => 'updated_at NUMD', :find => {:order => 'updated_at desc'}})
      fulltext_search(keyword, options)
    end

    # 全コミュニティのトピックをキーワード検索
    # TODO コミュニティ依存じゃないので TpcTopic に移動したい。。。けど、acts_as_searchable になっているのはここか。。。悩ましい
    def keyword_search(keyword, options = {})
      unless keyword
        keyword = ''
      end
      options.merge!({:order => 'updated_at NUMD', :find => {:order => 'updated_at desc'}})
      fulltext_search(keyword, options)
    end
  
    # 所属コミュニティの最新トピック
    def find_latest_topics_by_base_user_id_and_limit_days(base_user_id, limit_days, options = {})
      olddate = Time.now - 24*60*60*limit_days.to_i
      user = BaseUser.find(base_user_id)
      options.merge!({
        :conditions => ["(tpc_topics.created_at > ? or tpc_topics.last_commented_at > ?) and cmm_community_id in (?)",
           olddate, olddate, user.cmm_communities.map {|c| c.id} ],
        :order => 'tpc_topics.last_commented_at desc, tpc_topics.created_at desc',
        :include => :tpc_topic
      })
      
      TpcTopicCmmCommunity.find(:all, options)
    end
  
    # あるユーザがコメントしたことあるうちで最新のトピック
    # ただし、トピックは、現在所属しているコミュニティのものか、
    # (PUBLIC_LEVEL_LOGGED_IN より広い公開レベル && 強制退会させられたコミュニティ以外)のものに限る
    def find_commented_topics_by_base_user_id_and_limit_days(base_user_id, limit_days, options = {})
      olddate = Time.now - 24*60*60*limit_days.to_i
      rejected_communities = CmmCommunitiesBaseUser.find_rejected_communities_by_user_id(base_user_id)
      joined_communities = CmmCommunitiesBaseUser.find_joined_communities_by_user_id(base_user_id)
      comments = TpcComment.find(:all,
        :conditions => ["created_at > ? and base_user_id = ?", olddate, base_user_id])

      rejected_community_ids = rejected_communities.map{|c| c.cmm_community_id}
      rejected_community_ids = [-1] if rejected_community_ids.size == 0
      # rejected_communities が何もないときに "not in(null)" っていうSQL文になって、それがエラーの原因なのでとりあえずありえないIDを入れて回避
    
      options.merge!({
        :conditions => ["tpc_topic_id in (?) and cmm_community_id not in (?) and (cmm_community_id in (?) or public_level <= ?)",
          comments.map{|c| c.tpc_topic_id},
          rejected_community_ids,
          joined_communities.map{|c| c.cmm_community_id},
          TpcRelationSystem::PUBLIC_LEVEL_USER
          ],
        :order => 'tpc_topics.last_commented_at desc',
        :include => :tpc_topic
      })
    
      ttccs = TpcTopicCmmCommunity.find(:all, options)
      return ttccs
    end
  
  end

  # BaseUser もしくは、 base_user_id を引数にして、その人がトピックにアクセスできるか調べる
  def accessible?(base_user)
    return true if public_level == TpcRelationSystem::PUBLIC_LEVEL_ALL
    
    if base_user.kind_of? Integer
      base_user = BaseUser.find(base_user)
    elsif base_user == :false # ログインしていなければ
      return false
    end
    
    if public_level == TpcRelationSystem::PUBLIC_LEVEL_USER
      return true
    elsif public_level == TpcRelationSystem::PUBLIC_LEVEL_PARTICIPANT
      return cmm_community.joined?(base_user.id)
    end
    return false
  end

  # estraier に登録する内容の拡張
  def document_object_with_include
    doc = document_object_without_include
    doc.add_text tpc_topic.title
    doc.add_text tpc_topic.body

    self.tpc_topic.tpc_comments.each do |comment|
      if comment.not_invisibled_by_anyone?
        doc.add_text comment.body
      end
    end
    doc
  end
  
private

  def expire_portal_cache
    TpcTopicCmmCommunity.cache_portal_topics.each do | topic |
      if topic.id == self.id
        self.class.expire_cache("TpcTopicCmmCommunity#portal_topics")
        return # expire は一度だけ
      end
    end
  end
  
end
