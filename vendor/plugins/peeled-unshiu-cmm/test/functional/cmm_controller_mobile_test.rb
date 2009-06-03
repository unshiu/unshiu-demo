require File.dirname(__FILE__) + '/../test_helper'

module CmmControllerMobileTestModule 
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
      end
    end
  end
  
  def test_show
    get :show, :id => 1
    assert_response :success
    
    assert_instance_of CmmCommunity, assigns["community"]
    assert_equal CmmCommunity.find(1), assigns["community"]
  end

  define_method('test: show はコミュニティページを表示する') do
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
    
    assert_equal assigns["community"], CmmCommunity.find(1)
  end
  
  define_method('test: show はコミュニティページを表示し最新トピックを表示する') do
    login_as :quentin
    
    TpcTopic.record_timestamps = false
    topic = TpcTopic.create({:title => "new create", :body => "new create body", :base_user_id => 1, 
                             :created_at => Time.now + 1.years})
    TpcTopic.record_timestamps = true
    TpcTopicCmmCommunity.create({:tpc_topic_id => topic.id, :cmm_community_id => 1, :public_level => 1})
    
    get :show, :id => 1
    assert_response :success
    
    assert_equal assigns["community"], CmmCommunity.find(1)
    assert_not_equal(assigns["topics"].size, 0)
    assert_equal(assigns["topics"].to_a[0].tpc_topic.title, "new create") # 作成順
  end
  
  def test_list
    page_size = AppResources["cmm"]["community_list_size"]
 
    get :list
    communities = assigns["communities"]

    communities.each do |cmm|
      assert_instance_of CmmCommunity, cmm
    end
    
  end
  
  def test_search
    CmmCommunity.reindex!
    get :search, :keyword => "hello"
    
    keyword = assigns["keyword"]
    communities = assigns["communities"]
    
    assert_not_nil keyword
    assert_equal "hello", keyword

    assert_instance_of PagingEnumerator, communities
    assert_equal 1, communities.page
    assert_equal AppResources["cmm"]["community_list_size"], communities.page_size
    assert_equal 2, communities.size
    communities.each do |cmm|
      assert_instance_of CmmCommunity, cmm

    end
  end
  
  define_method('test: コミュニティの新規作成はログインしていないとできない') do
    login_required_test :new
  end
  
  def test_new
    community = CmmCommunity.new do |cmm|
                  cmm.name = "NEW COMMUNITY"
                  cmm.profile = "NEW COMMUNITY's PROFILE"
                end
                
    login_as :quentin
    get :new, :community => community.attributes
    assert_response :success
    
    community = assigns["community"]
    
    assert_instance_of CmmCommunity, community
    assert_equal "NEW COMMUNITY", community.name
    assert_equal "NEW COMMUNITY's PROFILE", community.profile
    assert_equal AppResources["cmm"]["default_join_type"], community.join_type
    assert_equal AppResources["cmm"]["default_topic_create_level"], community.topic_create_level
    
  end
  
  define_method('test: コミュニティ作成確認画面はログインしていないと閲覧できない') do
    login_required_test :create_done
  end
  
  def test_create_confirm
    community = CmmCommunity.new do |cmm|
                  cmm.name = "NEW COMMUNITY"
                  cmm.profile = "NEW COMMUNITY's PROFILE"
                  cmm.join_type = AppResources["cmm"]["default_join_type"]
                  cmm.topic_create_level = AppResources["cmm"]["default_topic_create_level"]
                end
    login_as :quentin
    get :create_confirm, :community => community.attributes
    assert_response :success
    
    community_in_res = assigns["community"]
    assert_equal "NEW COMMUNITY", community_in_res.name
    assert_equal "NEW COMMUNITY's PROFILE", community_in_res.profile
    assert_equal AppResources["cmm"]["default_join_type"], community_in_res.join_type
    assert_equal AppResources["cmm"]["default_topic_create_level"], community_in_res.topic_create_level

    # validにひっかかるCmmCommunityを渡す
    get :create_confirm, :community => CmmCommunity.new.attributes
    assert_response :success
    assert_template "new_mobile"
    
  end
  
  define_method('test: コミュニティ作成実行はログインしていないとできない') do
    login_required_test :create_complete
  end
  
  define_method('test: コミュニティ作成実行をする') do
    login_as :quentin
    
    community = CmmCommunity.new do |cmm|
      cmm.name = "NEW COMMUNITY"
      cmm.profile = "NEW COMMUNITY's PROFILE"
      cmm.join_type = AppResources["cmm"]["default_join_type"]
      cmm.topic_create_level = AppResources["cmm"]["default_topic_create_level"]
    end

    get :create_complete, :community => community.attributes
    
    create_community = CmmCommunity.find_by_name("NEW COMMUNITY")
    assert_not_nil(create_community)
    
    assert_response :redirect
    assert_redirected_to :action => :create_done , :id => create_community.id
  end
  
  define_method('test: コミュニティ作成完了画面はログインしていないと閲覧できない') do
    login_required_test :create_done
  end
  
  def test_create_done
    login_as :quentin
    
    get :create_done, :id => 1
    assert_response :success
  end
  
  define_method('test: コミュニティ参加確認画面はログインしていないと閲覧できない') do
    login_required_test :join_confirm
  end
  
  def test_join_confirm
    login_as :quentin
    
    get :join_confirm, :id => 1
    assert_response :success
    
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: コミュニティ参加実行はログインしていないとできない') do
    login_required_test :join_confirm
  end
  
  define_method('test: コミュニティ参加実行をする') do
    login_as :four
    
    get :join_complete, :id => 1
    assert_response :redirect
    assert_redirected_to :action => :join_done, :id => 1
  end
  
  define_method('test: 既に参加している人がコミュニティ参加実行をしようとするとエラー画面へ遷移する') do
    login_as :quentin
  
    get :join_complete, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code "U-03009"
  end
  
  define_method('test: コミュニティに参加をしようとしたがキャンセルする') do
    login_as :four
    
    get :join_complete, :id => 1, :cancel => "true"
    
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1 # キャンセルした場合コミュニティページへ戻る
  end
  
  define_method('test: コミュニティの参加確認画面はログインしていないと閲覧できない') do
    login_required_test :join_confirm
  end
  
  def test_join_done
    login_as :quentin
    
    get :join_confirm, :id => 1
    assert_response :success
    
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: コミュニティ脱退確認画面はログインしていないと閲覧できない') do
    login_required_test :resign_confirm
  end
  
  define_method('test: サブ管理者はコミュニティ脱退確認画面を表示できる') do
    login_as :quentin
    
    get :resign_confirm,  :id => 1
    assert_response :success
    
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: ゲストはコミュニティ脱退確認画面を表示できる') do
    login_as :three
    
    get :resign_confirm,  :id => 1
    assert_response :success
    
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: コミュニティ管理者は脱退できないのではコミュニティ脱退確認画面を表示しようとするとエラー画面を表示する') do
    login_as :aaron
    
    get :resign_confirm,  :id => 1
    assert_response :redirect
    assert_redirect_with_error_code "U-03010"
  end
  
  define_method('test: コミュニティ脱退実行はログインしていないと閲覧できない') do
    login_required_test :resign_complete
  end
  
  define_method('test: コミュニティ脱退実行をする') do
    login_as :quentin
    
    get :resign_complete, :id => 1
    assert_response :redirect
    assert_redirected_to :action => :resign_done, :id => 1
    
    cmm_base_user = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(1, 1)
    assert_nil cmm_base_user # 関連がなくなっている。
  end
  
  define_method('test: コミュニティ管理者はコミュニティの脱退ができないので実行しようとするとエラー画面へ遷移する') do
    login_as :aaron
    
    get :resign_confirm, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code "U-03010"
  end
  
  define_method('test: コミュニティ脱退実行をキャンセルボタンをおして回避したら脱退はされない') do
    login_as :quentin
    
    get :resign_complete, :id => 1, :cancel => "cancel"
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    cmm_base_user = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(1, 1)
    assert_not_nil cmm_base_user # キャンセルしたので関連はある。
  end
  
  define_method('test: コミュニティ脱退完了画面はログインしていないと閲覧できない') do
    login_required_test :resign_done
  end
  
  define_method('test: コミュニティ脱退完了画面を表示する') do
    login_as :quentin
    
    get :resign_done, :id => 1
    assert_response :success
    assert_template "cmm/resign_done_mobile"
  end
  
private
  
  def login_required_test(action)  
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/cmm/#{action}"
  end
  
end
