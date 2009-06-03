require File.dirname(__FILE__) + '/../test_helper'

module CmmCommunityTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :cmm_communities_base_users
        fixtures :cmm_communities
        fixtures :cmm_images
        fixtures :base_users
        
        self.use_transactional_fixtures = false
      end
    end
  end

  def test_relation
    cmm_community = CmmCommunity.find(1)
    assert_not_nil cmm_community.cmm_communities_base_users
    assert_not_nil cmm_community.base_users
  end
  
  def test_applying_users
    c1 = CmmCommunity.find(1)
    u1 = c1.applying_users
  end
  
  def test_rejected_users
    
  end
  
  def test_joined_users
    c1 = CmmCommunity.find(1)
    cmm_users = c1.admin_users
    
    assert_not_nil cmm_users
#    assert_equal 4, cmm_users.size
#    cmm_users.each do |cmm_user|
#      assert_not_equal 100, cmm_user.status
#      assert_not_equal nil, cmm_user.status
#    end
  end
  
  def test_admin_users
    c1 = CmmCommunity.find(1)
    cmm_users = c1.admin_users
    
    assert_not_nil cmm_users
    assert_equal 1, cmm_users.size
    cmm_users.each do |cmm_user|
      assert_equal 2, cmm_user.base_user_id
      assert_equal 1, cmm_user.status
    end
  end
  
  def test_join_type_free?
    c1 = CmmCommunity.find(1)
    c2 = CmmCommunity.find(2)
    c3 = CmmCommunity.find(3)
    c4 = CmmCommunity.find(4)
    
    assert c1.join_type_free?
    assert c2.join_type_free?
    assert !c3.join_type_free?
    assert !c4.join_type_free?
  end
  
  def test_join_type_need_approval?
    c1 = CmmCommunity.find(1)
    c2 = CmmCommunity.find(2)
    c3 = CmmCommunity.find(3)
    c4 = CmmCommunity.find(4)
    
    assert !c1.join_type_need_approval?
    assert !c2.join_type_need_approval?
    assert c3.join_type_need_approval?
    assert c4.join_type_need_approval?
  end
  
  def test_topic_create_level_member?
    c1 = CmmCommunity.find(1)
    c2 = CmmCommunity.find(2)
    c3 = CmmCommunity.find(3)
    
    assert c3.topic_create_level_member?
    assert !c1.topic_create_level_member?
  end
  
  def test_topic_create_level_admin?
    
  end
  
  def test_topic_creatable?
    c1 = CmmCommunity.find(1)
    
    assert c1.topic_creatable?(2)  # STATUS_ADMIN
    assert !c1.topic_creatable?(1) # STATUS_SUBADMIN
    assert !c1.topic_creatable?(4) # not joined
  end
  
  def test_applying?
    c1 = CmmCommunity.find(1)
    
    assert c1.applying?(5)   # STATUS_APPLYING
    assert !c1.applying?(1)  # STATUS_SUBADMIN
    assert !c1.applying?(nil)# nil check.
  end
  
  def test_rejected?
    c1 = CmmCommunity.find(1)
    
    assert !c1.rejected?(2)
    assert c1.rejected?(6)
    assert !c1.rejected?(nil)
  end
  
  def test_joined?
    c1 = CmmCommunity.find(1)
    
    assert c1.joined?(2)   # STATUS_ADMIN
    assert c1.joined?(1)   # STATUS_SUBADMIN
    assert !c1.joined?(5)  # STATUS_APPLYING
    assert !c1.joined?(99) # No such user.
    assert !c1.joined?(nil)# nil check.
    
    c2 = CmmCommunity.find(2)
    
    assert c2.joined?(1)   # STATUS_SUBADMIN
    assert !c2.joined?(2)  # Not joined user.
  end
  
  def test_admin?
    c1 = CmmCommunity.find(1)
    # 正常
    assert c1.admin?(2)
    
    # ADMINではないユーザ
    assert !c1.admin?(1)
    # 存在しないユーザ
    assert !c1.admin?(999)
    assert !c1.admin?(nil)
  end
  
  def test_admin_or_subadmin?
    c1 = CmmCommunity.find(1)

    # 正常
    assert c1.admin_or_subadmin?(2)
    assert c1.admin_or_subadmin?(1)
    
    # ADMINでもSUBADMINでもないユーザ
    assert !c1.admin_or_subadmin?(3)
    # 存在しないユーザ
    assert !c1.admin_or_subadmin?(999)
    # nil
    assert !c1.admin_or_subadmin?(nil)
  end
  
  def test_user_status_in?
    c1 = CmmCommunity.find(1)
    
    assert c1.user_status_in?(2, [1,2,10,20,50,100])# [STATUS_ADMIN,STATUS_SUBADMIN,STATUS_MEMBER,STATUS_GUEST,STATUS_APPLYING,STATUS_REJECTED]
    assert c1.user_status_in?(1, [2])               # [STATUS_SUBADMIN]
    assert c1.user_status_in?(3, [1,10,20])         # [STATUS_ADMIN,STATUS_MEMBER,STATUS_GUEST]
    
    assert !c1.user_status_in?(3, [50])             # [STATUS_APPLYING]
  end
  
  define_method('test: keyword_search は指定したキーワードを持つコミュニティを取得する') do
    CmmCommunity.clear_index!
    CmmCommunity.reindex!
    
    ret = CmmCommunity.keyword_search "hello"
    assert_not_nil ret
    assert_equal 2, ret.size
    ret.each do |cmm|
      assert_match "hello", cmm.profile
    end
    
    ret = CmmCommunity.keyword_search "hel"
    assert_not_nil ret
    assert_equal 2, ret.size
    ret.each do |cmm|
      assert_match "hello", cmm.profile
    end
    
    ret = CmmCommunity.keyword_search "two"
    assert_not_nil ret
    assert_equal 2, ret.size
  end
  
  define_method('test: receive はアップロードされたコミュニティの画像を保存する') do
    # 事前チェック:画像は設定されてない
    cmm_community = CmmCommunity.find(1)
    assert_nil cmm_community.cmm_image_id
    
    email = read_mail_fixture('base_mailer_notifier', 'cmm_community_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    CmmCommunity.receive(email, info)
    
    cmm_community = CmmCommunity.find(1)
    assert_not_nil cmm_community.cmm_image_id # 設定済み
    
    cmm_image = CmmImage.find(cmm_community.cmm_image_id)
    assert_not_nil cmm_image
  end
  
  define_method('test: receive は既に画像が設定済みならアップロードされたコミュニティの画像を更新する') do
    
    assert_difference 'CmmImage.count', 1 do # レコードが増える
      email = read_mail_fixture('base_mailer_notifier', 'cmm_community_receive')
      info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
      CmmCommunity.receive(email, info)
    end
  
    cmm_community = CmmCommunity.find(1)
    assert_not_nil cmm_community.cmm_image_id # 設定
    
    assert_difference 'CmmImage.count', 0 do # レコードが増えない
      email = read_mail_fixture('base_mailer_notifier', 'cmm_community_receive')
      info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
      CmmCommunity.receive(email, info)
    end
    
  end

  define_method('test: コミュニティの画像をアップロードしようとするが画像が大きすぎるため更新されない') do
    
    email = read_mail_fixture('base_mailer_notifier', 'cmm_community_bigger_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    CmmCommunity.receive(email, info)
    
    cmm_community = CmmCommunity.find(1)
    assert_nil cmm_community.cmm_image_id # 設定されてない
  end
  
  define_method('test: キャッシュされたコミュニティ一覧を取得する') do
    CmmCommunity.expire_cache("CmmCommunity#portal_communities") # テスト用にキャッシュ情報はクリアしておく
    CmmCommunity.record_timestamps = false 
    
    before_all_count = CmmCommunity.count(:all)
    
    before_communities = CmmCommunity.cache_portal_communities # キャッシュ作成
    assert_equal(before_communities.size, 3)
    
    # コミュニティを作成
    cmm_community = CmmCommunity.new({:name => "テスト", :profile => "プロフィール", :join_type => 1,
                                      :topic_create_level => 1, :created_at => Time.now.tomorrow})
    cmm_community.save!
    
    # キャッシュは更新されていない 
    cache_communities = CmmCommunity.cache_portal_communities 
    assert_equal(cache_communities.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないので個別にを比較
      assert_equal(before_communities[index], cache_communities[index])
    end
    
    after_all_count = CmmCommunity.count(:all) 
    assert_equal(after_all_count, before_all_count + 1) # 実数は増えている
    
    CmmCommunity.record_timestamps = true
  end
  
  define_method('test: キャッシュされたコミュニティ一覧はキャッシュ対象が削除されると情報をクリアする') do
    CmmCommunity.expire_cache("CmmCommunity#portal_communities") # テスト用にキャッシュ情報はクリアしておく
    
    before_all_count = CmmCommunity.count(:all)
    
    before_communities = CmmCommunity.cache_portal_communities # キャッシュ作成
    assert_equal(before_communities.size, 3)
    
    # コミュニティ削除
    community = CmmCommunity.find(1)
    community.destroy!
    
    cache_communities = CmmCommunity.cache_portal_communities # キャッシュは更新されている
    assert_equal(cache_communities.size, 3)
    cache_communities.each do |cache_community| # キャッシュに削除したコミュニティは存在しない
      assert_not_equal(cache_community, community)
    end
    
    after_all_count = CmmCommunity.count(:all) 
    assert_equal(after_all_count, before_all_count - 1) # 実数はへっている
  end
  
  define_method('test: コミュニティが削除されたがキャッシュ対象ではないので情報はクリアしない') do
    CmmCommunity.expire_cache("CmmCommunity#portal_communities") # テスト用にキャッシュ情報はクリアしておく
    CmmCommunity.record_timestamps = false 
    
    before_all_count = CmmCommunity.count(:all)
    
    before_communities = CmmCommunity.cache_portal_communities # キャッシュ作成
    assert_equal(before_communities.size, 3)
    
    # コミュニティを作成
    cmm_community = CmmCommunity.new({:name => "テスト", :profile => "プロフィール", :join_type => 1,
                                      :topic_create_level => 1, :created_at => Time.now.tomorrow})
    cmm_community.save!
    
    cmm_community = CmmCommunity.new({:name => "テスト2", :profile => "プロフィール", :join_type => 1,
                                      :topic_create_level => 1, :created_at => Time.now.tomorrow})
    cmm_community.save!
    
    # キャッシュクリア対象外のアルバムを削除
    non_cache_cmmunity = CmmCommunity.find(4)
    non_cache_cmmunity.destroy!
    
    # キャッシュは更新されていない
    cache_communities = CmmCommunity.cache_portal_communities
    assert_equal(cache_communities.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないのでidを比較
      assert_equal(before_communities[index], cache_communities[index])
    end
    
    after_all_count = CmmCommunity.count(:all) # 実数は増加している
    assert_equal(after_all_count, before_all_count + 1)
    
    CmmCommunity.record_timestamps = true  
  end
  
  define_method('test: 参加タイプ名を取得する') do
    cmm_community = CmmCommunity.new
    cmm_community.join_type = 0
    assert_equal(cmm_community.join_type_name, "自由参加")
    
    cmm_community.join_type = 1
    assert_equal(cmm_community.join_type_name, "管理人の承認が必要")
  end
  
  define_method('test: 指定ユーザのコミュニティ内での立場を返す') do
    cmm_community = CmmCommunity.find(1)
    assert_equal(cmm_community.user_status_name(1), "サブ管理者")
    assert_equal(cmm_community.user_status_name(2), "管理者")
    assert_nil(cmm_community.user_status_name(999)) # 参加していなければnil
  end
  
  define_method('test: topic_create_level_name はトピック作成レベル名を返す') do
    cmm_community = CmmCommunity.new
    cmm_community.topic_create_level = CmmCommunitiesBaseUser::STATUS_ADMIN
    assert_equal(cmm_community.topic_create_level_name, "管理者のみ")
    cmm_community.topic_create_level = CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_equal(cmm_community.topic_create_level_name, "参加者なら誰でも")
  end
end
