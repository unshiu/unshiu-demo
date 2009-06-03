
module Manage::CmmControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest

        fixtures :base_users
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
      end
    end
  end    

  def test_index
    login_as :quentin
    
    get :index
    assert_response :redirect
    assert_redirected_to :action => :list
  end

  def test_show
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
  
    community = assigns["community"]
  
    assert_not_nil community
    assert_instance_of CmmCommunity, community
    assert_equal CmmCommunity.find(1), community
  end

  def test_list
    login_as :quentin
    
    get :list
    assert_response :success
  
    communities = assigns["communities"]
  
    assert_not_nil communities
    assert_instance_of PagingEnumerator, communities
    communities.each do |cmm|
      assert_instance_of CmmCommunity, cmm
    end
  end

  def test_search
    login_as :quentin
    
    CmmCommunity.reindex!
  
    get :search, :keyword => "hello"
    assert_response :success
    assert_template "list"
  
    keyword = assigns["keyword"]
    communities = assigns["communities"]
  
    assert_not_nil keyword
    assert_equal "hello", keyword
    assert_not_nil communities
    assert_instance_of PagingEnumerator, communities
    assert_equal 2, communities.size
    communities.each do |cmm|
      assert_instance_of CmmCommunity, cmm
    end
  end

  define_method('test: コミュニティの参加者一覧を表示する') do
    login_as :quentin
    
    get :member_list, :id => 1
    assert_response :success
  
    assert_not_nil(assigns["state"])
    assert_not_nil(assigns["community"])
    assert_not_nil(assigns["members"])
    assert_not_equal(assigns["members"].size, 0) # 念のためデータはあるかどうか確認
    
    cmm_community = CmmCommunity.find(1)
    assert_equal CmmCommunitiesBaseUser::STATUS_NONE, assigns["state"]
    assert_equal cmm_community, assigns["community"]
    assert_instance_of PagingEnumerator, assigns["members"]
    assigns["members"].each do |member|
      assert_instance_of CmmCommunitiesBaseUser, member
      assert CmmCommunitiesBaseUser::STATUSES_JOIN.index(member.status)
    end
  end
  
  define_method('test: コミュニティのメンバー一覧を表示する') do
    login_as :quentin
    
    get :member_list, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :success
  
    assert_not_nil(assigns["state"])
    assert_not_nil(assigns["community"])
    assert_not_nil(assigns["members"])
    assert_not_equal(assigns["members"].size, 0) # 念のためデータはあるかどうか確認
    
    cmm_community = CmmCommunity.find(1)
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, assigns["state"]
    assert_equal cmm_community, assigns["community"]
    
    assert_instance_of PagingEnumerator, assigns["members"]
    assigns["members"].each do |member|
      assert_instance_of CmmCommunitiesBaseUser, member
      assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, member.status
    end
  end

  define_method('test: コミュニティのアクセス禁止ユーザ一覧を表示する') do
    login_as :quentin
    
    get :member_list, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_REJECTED
    assert_response :success
  
    assert_not_nil(assigns["state"])
    assert_not_nil(assigns["community"])
    assert_not_nil(assigns["members"])
    assert_not_equal(assigns["members"].size, 0) # 念のためデータはあるかどうか確認
    
    cmm_community = CmmCommunity.find(1)
    assert_equal CmmCommunitiesBaseUser::STATUS_REJECTED, assigns["state"]
    assert_equal cmm_community, assigns["community"]
    assert_instance_of PagingEnumerator, assigns["members"]
    
    assigns["members"].each do |member|
      assert_instance_of CmmCommunitiesBaseUser, member
      assert_equal CmmCommunitiesBaseUser::STATUS_REJECTED, member.status
    end
  end
  
  def test_destroy_confirm
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
  
    community = assigns["community"]
  
    assert_not_nil community
    assert_instance_of CmmCommunity, community
    assert_equal 1, community.id
  end

  def test_destroy_complete
    login_as :quentin
    
    post :destroy_complete, :id => 1
    assert_response :redirect
    assert_redirected_to :action => :list
  
    assert_raise(ActiveRecord::RecordNotFound) do
      CmmCommunity.find(1)
    end
  end

  def test_destroy_complete__cancel
    login_as :quentin
    
    post :destroy_complete, :id => 1, :cancel => "cancel"
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
  
    assert_instance_of CmmCommunity, CmmCommunity.find(1)
  end

  def test_search_redirector
    login_as :quentin
    
    get :search_redirector, :keyword => "hello", :type => 0
    assert_response :redirect
    assert_redirected_to :controller => "manage/cmm", :action => :search, :keyword => "hello"
  
    get :search_redirector, :keyword => "hello", :type => 1
    assert_response :redirect
    assert_redirected_to :controller => "manage/tpc_cmm", :action => :allsearch, :keyword => "hello"
  
    get :search_redirector, :keyword => "hello", :type => 2
    assert_response :redirect
    assert_redirected_to :controller => "manage/tpc_cmm", :action => :search, :keyword => "hello"
  end
  
end