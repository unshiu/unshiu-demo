# == Schema Information
#
# Table name: cmm_communities
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)     default(""), not null
#  profile            :text
#  image_file_name    :string(255)
#  join_type          :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#  deleted_at         :datetime
#  topic_create_level :integer(4)
#  cmm_image_id       :integer(4)
#

#= コミュニティを表すモデルクラス。
# コミュニティはトピックを複数持つ。
module CmmCommunityModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        acts_as_cached
        
        has_many :cmm_communities_base_users, :dependent => :destroy
        has_many :base_users, :through => :cmm_communities_base_users
        has_many :tpc_topic_cmm_communities, :dependent => :destroy
        has_many :tpc_topics, :through => :tpc_topic_cmm_communities
        has_one :cmm_image, :dependent => :destroy

        acts_as_searchable :searchable_fields => [:name, :profile],
                           :attributes => {:updated_at => :updated_at}

        validates_length_of :name, :maximum => AppResources['base']['title_max_length']
        validates_length_of :profile, :maximum => AppResources['base']['body_max_length']
        validates_uniqueness_of :name
        validates_presence_of :name, :profile
        validates_good_word_of :name, :profile
        validates_numericality_of :join_type, :topic_create_level
        
        before_destroy :expire_portal_cache
        
        # 参加に承認が必要ならJOIN_TYPE_NEED_APPROVAL
        const_set('JOIN_TYPE_FREE', 0)
        const_set('JOIN_TYPE_NEED_APPROVAL', 1)
        
      end
    end
  end
  
  def applying_users
    # TODO: なんかもうすこし効率いい方法ありそう
    return cmm_communities_base_users.reject {|c| !c.applying?}
  end
  def rejected_users
    return cmm_communities_base_users.reject {|c| !c.rejected?}
  end
  def joined_users
    return CmmCommunitiesBaseUser.find_joined_by_community_id(id)
  end
  def admin_users
    return cmm_communities_base_users.reject {|c| !c.admin?}
  end

  def join_type_free?
    return join_type == CmmCommunity::JOIN_TYPE_FREE 
  end
  def join_type_need_approval?
    return join_type == CmmCommunity::JOIN_TYPE_NEED_APPROVAL
  end
  
  def topic_create_level_member?
    return topic_create_level == CmmCommunitiesBaseUser::STATUS_MEMBER
  end
  def topic_create_level_admin?
    return topic_create_level == CmmCommunitiesBaseUser::STATUS_ADMIN
  end
  
  # トピック作成タイプ名称を返す
  # return:: 参加タイプ名称
  def topic_create_level_name
    if topic_create_level_member?
      I18n.t("view.noun.topic_create_level_member")
    elsif topic_create_level_admin?
      I18n.t("view.noun.topic_create_level_admin")
    end
  end
  
  # base_user_idのユーザーがこのコミュニティでトピックを作成可能ならtrue。さもなくばfalseを返す。
  # トピックを作成可能なユーザーはコミュニティに参加しているユーザー、管理者、トピック作成可能ユーザー。
  def topic_creatable?(base_user_id)
    return false unless joined?(base_user_id)
    return true if admin?(base_user_id)
    return true if topic_create_level_member?
    return false
  end
  
  # base_user_idのユーザーがこのコミュニティに参加申請中ならtrue。さもなくばfalseを返す。
  def applying?(base_user_id)
    return user_status_equals?(base_user_id, CmmCommunitiesBaseUser::STATUS_APPLYING)
  end
  
  # base_user_idのユーザーがコミュニティ参加拒否されているならtrue。さもなくばfalseを返す。
  # 拒否されているユーザーはステータスが参加拒否のユーザー。
  def rejected?(base_user_id)
    return user_status_equals?(base_user_id, CmmCommunitiesBaseUser::STATUS_REJECTED)
  end
  
  # このコミュニティにbase_user_idのユーザーが参加していればtrue。さもなければfalseを返す。
  # 参加しているユーザーはコミュニティ管理者、コミュニティサブ管理者、コミュニティメンバー、ゲストのいずれか。
  def joined?(base_user_id)
    return user_status_in?(base_user_id, [CmmCommunitiesBaseUser::STATUS_ADMIN, CmmCommunitiesBaseUser::STATUS_SUBADMIN, CmmCommunitiesBaseUser::STATUS_MEMBER, CmmCommunitiesBaseUser::STATUS_GUEST])
  end
  
  # base_user_idのユーザがコミュニティの管理者ならtrue。さもなければfalseを返す。
  def admin?(base_user_id)
    return user_status_equals?(base_user_id, CmmCommunitiesBaseUser::STATUS_ADMIN)
  end
  
  # base_user_idのユーザがコミュニティの管理者かサブ管理者ならtrue。さもなければfalseを返す。
  def admin_or_subadmin?(base_user_id)
    return user_status_in?(base_user_id, [CmmCommunitiesBaseUser::STATUS_ADMIN, CmmCommunitiesBaseUser::STATUS_SUBADMIN])
  end

  # base_user_idのユーザがこのコミュニティのstatusesのいずれかの権限を持っていればtrueを返す。さもなければfalseを返す。
  def user_status_in?(base_user_id, statuses)
    ccbu = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(id, base_user_id)
    return false unless ccbu
    statuses.each do |s|
      return true if ccbu.status == s
    end
    return false
  end

  # 指定ユーザのこのコミュニティでの立場を返す。参加していなければnilがかえる。
  # _param1_:: base_user_id
  # return:: 立場名称
  def user_status_name(base_user_id)
    ccbu = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(self.id, base_user_id)
    ccbu ? ccbu.status_name : nil
  end
  
  # 参加タイプ名称を返す
  # return:: 参加タイプ名称
  def join_type_name
    if join_type_free?
      I18n.t("view.noun.join_type_free")
    elsif join_type_need_approval?
      I18n.t("view.noun.join_type_need_approval")
    end
  end
  
  module ClassMethods
    
    # クエリキャッシュの生存時間
    def ttl
      AppResources[:cmm][:cmm_community_cache_time]
    end
    
    # コミュニティをキーワード検索
    def keyword_search(keyword, options = {})
      unless keyword
        keyword = ''
      end
   
      options.merge!({:order => 'updated_at NUMD', :find => {:order => 'updated_at desc'}})
      fulltext_search(keyword, options)
    end

    # ポータル用にコミュニティ一覧を返す
    # 内容はキャッシュされており、一定期間経つか、該当コミュニティの一つが削除されるまで同じものがかえされる
    # return:: コミュニティ一覧
    def cache_portal_communities
      CmmCommunity.get_cache("CmmCommunity#portal_communities") do
        find(:all, :limit => AppResources[:cmm][:portal_community_list_size], :order => 'created_at desc' )
      end
    end
    
    # 画像付きメールを受信し、コミュニティ画像として設定する
    # _param1_:: mail 
    # _param2_:: base_mail_dispatch_info
    def receive(mail, base_mail_dispatch_info)
      unless mail.has_attachments?
        BaseMailerNotifier::deliver_failure_saving_cmm_images(mail, '画像が添付されていません')
        return
      end
      
      if mail.attachments.size > 1 # 添付ファイルがあり過ぎる
        BaseMailerNotifier::deliver_failure_saving_cmm_images(mail, '添付された画像が2つ以上あります。')
        return
      end
      
      unless BaseMailerNotifier.image?( mail.attachments.first) # 画像じゃない
        BaseMailerNotifier::deliver_failure_saving_cmm_images(mail, '添付ファイルが画像ではありません。')
        return
      end
      
      CmmCommunity.transaction { receive_core(mail, base_mail_dispatch_info) }

      BaseMailerNotifier::deliver_success_saving_cmm_images(mail, base_mail_dispatch_info.model_id)
    rescue => ex
      logger.info ex.to_s
      BaseMailerNotifier::deliver_failure_saving_cmm_images(mail)
    end
    
  private

    # コミュニティ画像を受信したときのメインの処理
    # _param1_:: mail
    # _param2_:: base_mail_dispatch_info
    def receive_core(mail, base_mail_dispatch_info)
      community = CmmCommunity.find(base_mail_dispatch_info.model_id)
      if community.cmm_image_id.nil?
        image = CmmImage.new({:cmm_community_id => base_mail_dispatch_info.model_id, :image => mail.attachments.first})
        image.save!
        community.cmm_image_id = image.id
        community.save!
        
      else
        image.image = mail.attachments.first        
        image.save!
      end
    end
      
  end
  
private

  def user_status_equals?(base_user_id, status)
    ccbu = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(id, base_user_id)
    return ccbu && ccbu.status == status
  end

  def expire_portal_cache
    CmmCommunity.cache_portal_communities.each do | community |
      if community.id == self.id
        self.class.expire_cache("CmmCommunity#portal_communities")
        return # expire は一度だけ
      end
    end
  end
end

