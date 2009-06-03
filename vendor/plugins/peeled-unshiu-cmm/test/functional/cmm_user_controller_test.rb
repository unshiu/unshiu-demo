require File.dirname(__FILE__) + '/../test_helper'

module CmmUserControllerTestModule
  
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
  
  define_method("test: ユーザが所属してるコミュニティ一覧はログインしていないと閲覧できない") do
    login_required_test :list
  end
  
  define_method("test: ユーザが所属してるコミュニティ一覧を表示する") do
    login_as :quentin
    
    get :list, :id => 1
    assert_response :success
    
    assert_instance_of BaseUser, assigns["user"]
    assert_equal 1, assigns["user"].id
    assert_instance_of PagingEnumerator, assigns["communities"]
    assert_equal AppResources['cmm']['community_list_size'], assigns["communities"].page_size
    
    assigns["communities"].each do |cmm_user|
      assert_instance_of CmmCommunitiesBaseUser, cmm_user
      assert_equal cmm_user.base_user_id, 1
    end
  end
  
  define_method("test: ユーザが所属してるコミュニティ一覧はidがなければログインしているユーザidで取得し表示する") do
    login_as :quentin
    
    get :list
    assert_response :success
    
    assert_instance_of BaseUser, assigns["user"]
    assert_equal 1, assigns["user"].id
    assert_instance_of PagingEnumerator, assigns["communities"]
    assert_equal AppResources['cmm']['community_list_size'], assigns["communities"].page_size
    assigns["communities"].each do |cmm_user|
      assert_instance_of CmmCommunitiesBaseUser, cmm_user
      assert_equal cmm_user.base_user_id, 1
    end
  end
  
private
  
  def login_required_test(action)  
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/cmm_user/#{action}"
  end
end
