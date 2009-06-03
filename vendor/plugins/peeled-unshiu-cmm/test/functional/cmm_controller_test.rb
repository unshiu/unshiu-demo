require File.dirname(__FILE__) + '/../test_helper'

module CmmControllerTestModule 
  
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
  
  define_method('test: コミュニティの新規作成はログインしていないとできない') do
    login_required_test :new
  end
  
  define_method('test: コミュニティの新規作成画面を表示する') do
    login_as :quentin
    
    get :new
    assert_response :success
    assert_template "new"
  end
  
  define_method('test: コミュニティの新規作成実行はログインしていないとできない') do
    login_required_test :create_complete
  end
  
  define_method('test: コミュニティを新規作成を実行する') do
    login_as :quentin
    
    post :create_complete, :community => {:name => "NEW COMMUNITY", :profile => "NEW COMMUNITY's PROFILE",
                                          :join_type => 1, :topic_create_level => 1}
    
    create_community = CmmCommunity.find_by_name("NEW COMMUNITY")
    assert_not_nil(create_community)

    assert_response :redirect
    assert_redirected_to :controller => :cmm_user, :action => :list
  end
  
  define_method('test: create_complete はコミュニティを新規作成内容に問題あがれば作成画面へ戻りエラーを表示する') do
    login_as :quentin
    
    post :create_complete, :community => {:name => "", :profile => "NEW COMMUNITY's PROFILE",
                                          :join_type => 1, :topic_create_level => 1}
    
    assert_response :success
    assert_template "new"
    
    create_community = CmmCommunity.find_by_name("")
    assert_nil(create_community) # 作成されてない
  end
  
  define_method('test: 全体に公開されいてるコミュニティは非ログイン状態でも閲覧できる') do
     get :show, :id => 1
     assert_response :success

     assert_instance_of CmmCommunity, assigns["community"]
     assert_equal CmmCommunity.find(1), assigns["community"]
     assert_not_nil assigns["members"]
   end

   define_method('test: コミュニティページを表示する') do
     login_as :quentin

     get :show, :id => 1
     assert_response :success

     assert_instance_of CmmCommunity, assigns["community"]
     assert_equal assigns["community"], CmmCommunity.find(1)
     assert_not_nil assigns["members"]
   end
   
   define_method('test: join_complete はコミュニティ参加実行をする') do
     login_as :four

     get :join_complete, :id => 1
     assert_response :redirect
     assert_redirected_to :controller => :cmm, :action => :show, :id => 1
   end

   define_method('test: join_complete は既に参加している人がコミュニティ参加実行をしようとするとエラー画面へ遷移する') do
     login_as :quentin

     get :join_complete, :id => 1
     assert_response :redirect
     assert_redirect_with_error_code "U-03009"
   end
   
   define_method('test: resign_confirm はログインしていないとコミュニティ脱退確認画面を表示しない') do
     login_required_test :resign_confirm
   end

   define_method('test: resign_confirm はサブ管理者ならコミュニティ脱退確認画面を表示する') do
     login_as :quentin

     get :resign_confirm,  :id => 1
     assert_response :success

     assert_equal CmmCommunity.find(1), assigns["community"]
   end

   define_method('test: resign_confirm はゲストはコミュニティ脱退確認画面を表示できる') do
     login_as :three

     get :resign_confirm,  :id => 1
     assert_response :success

     assert_equal CmmCommunity.find(1), assigns["community"]
   end

   define_method('test: resign_confirm はコミュニティ管理者は脱退できないのではコミュニティ脱退確認画面を表示しようとするとエラー画面を表示する') do
     login_as :aaron

     get :resign_confirm,  :id => 1
     assert_response :redirect
     assert_redirect_with_error_code "U-03010"
   end

   define_method('test: resign_complete はコミュニティ脱退実行はログインしていないと実行できない') do
     login_required_test :resign_complete
   end

   define_method('test: resign_complete はコミュニティ脱退実行をする') do
     login_as :quentin

     get :resign_complete, :id => 1
     assert_response :redirect
     assert_redirected_to :controller => :cmm_user, :action => :list

     cmm_base_user = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(1, 1)
     assert_nil cmm_base_user # 関連がなくなっている。
   end

   define_method('test: resign_complete はコミュニティ管理者はコミュニティの脱退ができないので実行しようとするとエラー画面へ遷移する') do
     login_as :aaron

     get :resign_complete, :id => 1
     assert_response :redirect
     assert_redirect_with_error_code "U-03011"
   end

   define_method('test: resign_complete はキャンセルボタンをおしたらコミュニティ脱退実行を回避し、脱退はされない') do
     login_as :quentin

     get :resign_complete, :id => 1, :cancel => "cancel"
     assert_response :redirect
     assert_redirected_to :action => :show, :id => 1

     cmm_base_user = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(1, 1)
     assert_not_nil cmm_base_user # キャンセルしたので関連はある。
   end
   
private
  
  def login_required_test(action)  
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/cmm/#{action}"
  end
  
end
