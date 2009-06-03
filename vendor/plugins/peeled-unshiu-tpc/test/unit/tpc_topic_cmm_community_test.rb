require File.dirname(__FILE__) + '/../test_helper'

module TpcTopicCmmCommunityTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :base_users
        fixtures :tpc_topics
        fixtures :tpc_comments
        fixtures :tpc_topic_cmm_communities
      end
    end
  end
  
  define_method('test: 全体公開のトピック一覧を取得する') do
    tcs = TpcTopicCmmCommunity.public_topics
    
    assert_not_nil tcs
    assert_equal tcs.length, 4
    tcs.each do |tc|
      assert_equal tc.public_level, TpcRelationSystem::PUBLIC_LEVEL_ALL
    end
  end
  
  define_method('test: キャッシュされたトピック一覧を取得する') do
    TpcTopicCmmCommunity.expire_cache("TpcTopicCmmCommunity#portal_topics") # テスト用にキャッシュ情報はクリアしておく
    TpcTopicCmmCommunity.record_timestamps = false 
    
    before_all_count = TpcTopicCmmCommunity.count(:all)
    
    before_topics = TpcTopicCmmCommunity.cache_portal_topics # キャッシュ作成
    assert_equal(before_topics.size, 3)
    
    # コミュニティを作成
    topic = TpcTopicCmmCommunity.new({:tpc_topic_id => 1, :cmm_community_id => 1, :public_level => TpcRelationSystem::PUBLIC_LEVEL_ALL,
                                      :created_at => Time.now.tomorrow, :updated_at => Time.now.tomorrow})
    topic.save!
    
    # キャッシュは更新されていない 
    cache_topics = TpcTopicCmmCommunity.cache_portal_topics 
    assert_equal(cache_topics.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないので個別にを比較
      assert_equal(before_topics[index], cache_topics[index])
    end
    
    after_all_count = TpcTopicCmmCommunity.count(:all) 
    assert_equal(after_all_count, before_all_count + 1) # 実数は増えている
    
    TpcTopicCmmCommunity.record_timestamps = true
  end
  
  define_method('test: キャッシュされたトピック一覧はキャッシュ対象が削除されると情報をクリアする') do
    TpcTopicCmmCommunity.expire_cache("TpcTopicCmmCommunity#portal_topics") # テスト用にキャッシュ情報はクリアしておく
    
    before_all_count = TpcTopicCmmCommunity.count(:all)
    
    before_topics = TpcTopicCmmCommunity.cache_portal_topics # キャッシュ作成
    assert_equal(before_topics.size, 3)
    
    # トピック削除 関連、本体それぞれ
    topic = TpcTopicCmmCommunity.find(2)
    topic.destroy! 
    topic.tpc_topic.destroy! 
    
    cache_topics = TpcTopicCmmCommunity.cache_portal_topics 
    assert_equal(cache_topics.size, 3)
    cache_topics.each do |cache_topic| # キャッシュに削除したトピックは存在しない
      assert_not_equal(cache_topic, topic)
    end
    
    after_all_count = TpcTopicCmmCommunity.count(:all) 
    assert_equal(after_all_count, before_all_count - 1) # 実数はへっている
  end
  
  define_method('test: トピックが削除されたがキャッシュ対象ではないので情報はクリアしない') do
    TpcTopicCmmCommunity.expire_cache("TpcTopicCmmCommunity#portal_topics") # テスト用にキャッシュ情報はクリアしておく
    TpcTopicCmmCommunity.record_timestamps = false
    
    before_all_count = TpcTopicCmmCommunity.count(:all)
    
    before_topics = TpcTopicCmmCommunity.cache_portal_topics # キャッシュ作成
    assert_equal(before_topics.size, 3)
    
    # トピックを作成
    topic = TpcTopicCmmCommunity.new({:tpc_topic_id => 1, :cmm_community_id => 1, :public_level => TpcRelationSystem::PUBLIC_LEVEL_ALL,
                                      :created_at => Time.now.tomorrow, :updated_at => Time.now.tomorrow})
    topic.save!
    
    topic = TpcTopicCmmCommunity.new({:tpc_topic_id => 1, :cmm_community_id => 1, :public_level => TpcRelationSystem::PUBLIC_LEVEL_ALL,
                                      :created_at => Time.now.tomorrow, :updated_at => Time.now.tomorrow})
    topic.save!
    
    # キャッシュクリア対象外のトピックを削除
    non_cache_topic = TpcTopicCmmCommunity.find(1)
    non_cache_topic.destroy!
    
    # キャッシュは更新されていない
    cache_topics = TpcTopicCmmCommunity.cache_portal_topics
    assert_equal(cache_topics.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないので個別に比較
      assert_equal(before_topics[index], cache_topics[index])
    end
    
    after_all_count = TpcTopicCmmCommunity.count(:all) # 実数は増加している
    assert_equal(after_all_count, before_all_count + 1)
    
    TpcTopicCmmCommunity.record_timestamps = true  
  end
  
  define_method('test: 指定コミュニティの指定公開レベル以下のトピックを取得する') do
    # ユーザ公開以下（ユーザ公開、全体公開への公開：コミュニティのみ公開は含まない）のトピックを取得
    tcs = TpcTopicCmmCommunity.find_by_community_id_and_max_public_level(1, TpcRelationSystem::PUBLIC_LEVEL_USER)
    assert_equal 2, tcs.length
    tcs.each do |t|
      assert_equal 1, t.cmm_community_id
      assert t.public_level <= TpcRelationSystem::PUBLIC_LEVEL_USER
    end
  end
  
  # あるコミュニティのトピックをキーワード検索するテスト
  def test_keyword_search_by_community_id_and_max_public_level
    TpcTopicCmmCommunity.clear_index!
    TpcTopicCmmCommunity.reindex!
    
    tcs = TpcTopicCmmCommunity.keyword_search_by_community_id_and_max_public_level(2, TpcRelationSystem::PUBLIC_LEVEL_USER, 'あああ')
    assert_not_nil tcs
    assert_equal 2, tcs.length
    tcs.each do |tc|
      assert_equal 2, tc.cmm_community_id
    end
    
    # options渡しテスト
    # :orderは内部で上書きされるので意味なし。
    tcs = TpcTopicCmmCommunity.keyword_search_by_community_id_and_max_public_level(2, TpcRelationSystem::PUBLIC_LEVEL_USER, 'あああ', :find => {:order => "id desc"})
    assert_not_nil tcs
    assert_equal 2, tcs.length
  end
  
  # 全コミュニティのトピックをキーワード検索するテスト
  def test_keyword_search
    TpcTopicCmmCommunity.clear_index!
    TpcTopicCmmCommunity.reindex!
    
    tcs = TpcTopicCmmCommunity.keyword_search('あああ')    
    assert_not_nil tcs
    assert_equal 3, tcs.length
    
    # options渡しテスト
    # :orderは内部で上書きされるので意味なし。
    tcs = TpcTopicCmmCommunity.keyword_search('あああ', :find => {:order => "id desc"})
    assert_not_nil tcs
    assert_equal 3, tcs.length
  end
  
  def test_find_latest_topics_by_base_user_id_and_limit_days
    # base_user 1 は cmm_community 1,2 に所属している
    base_user_id = 1
    limit_days = 3
    
    tcs = TpcTopicCmmCommunity.find_latest_topics_by_base_user_id_and_limit_days(base_user_id, limit_days)    
    assert_not_nil tcs
    assert_equal 3, tcs.length

    # options渡しテスト
    # :orderは内部で上書きされるので意味なし。
    tcs = TpcTopicCmmCommunity.find_latest_topics_by_base_user_id_and_limit_days(base_user_id, limit_days, :order => 'id desc') 
    assert_not_nil tcs
    assert_equal 3, tcs.length
  end
  
  def test_find_commented_topics_by_base_user_id_and_limit_days
    # 1日前と5日前に別のトピックにコメントしているユーザー
    base_user_id = 1
    limit_days = 3
    
    tcs = TpcTopicCmmCommunity.find_commented_topics_by_base_user_id_and_limit_days(base_user_id, limit_days)    
    assert_not_nil tcs
    assert_equal 1, tcs.length

    # 1つコメントしているけど、そのコミュから強制退会させられているユーザ
    base_user_id = 6
    tcs = TpcTopicCmmCommunity.find_commented_topics_by_base_user_id_and_limit_days(base_user_id, limit_days)    
    assert_not_nil tcs
    assert_equal 0, tcs.length

    # options渡しテスト
    # :orderは内部で上書きされるので意味なし。
    base_user_id = 1
    tcs = TpcTopicCmmCommunity.find_commented_topics_by_base_user_id_and_limit_days(base_user_id, limit_days, :order => 'id desc') 
    assert_not_nil tcs
    assert_equal 1, tcs.length
  end
  
  # public_level_xxx? のテストは省略
  
  define_method('test: ログインしたユーザのみアクセス可能') do
    base_user = BaseUser.find(1)
    
    ttcc = TpcTopicCmmCommunity.find(1)
    assert ttcc.accessible?(base_user)
    assert ttcc.accessible?(1)
    assert !ttcc.accessible?(:false)
  end
  
  define_method('test: 全体（非ログインユーザを含む）でアクセス可能') do
    base_user = BaseUser.find(1)
    
    ttcc = TpcTopicCmmCommunity.find(4)
    assert ttcc.accessible?(base_user)
    assert ttcc.accessible?(1)
    assert ttcc.accessible?(:false)
  end
  
  define_method('test: コミュニティ参加者のみアクセス可能') do
    base_user = BaseUser.find(1)
    
    ttcc = TpcTopicCmmCommunity.find(6)
    assert !ttcc.accessible?(base_user)
    assert !ttcc.accessible?(1)
    assert !ttcc.accessible?(:false)
    assert ttcc.accessible?(BaseUser.find(2))
    assert ttcc.accessible?(2)
  end

  # document_object_with_include のテストは keyword_search のテストで代用
end