require "#{File.dirname(__FILE__)}/../test_helper"

module CmmControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
        fixtures :base_mail_dispatch_infos
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 参加処理実行に失敗したためエラー画面へ遷移') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm/join_complete", :id => 3
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03009"
  end
  
  define_method('test: 脱退しようとしたが管理者であったため脱退不可、よってエラー画面へ遷移') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm/resign_confirm", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03010"
  end
  
  define_method('test: 脱退実行しようとしたが管理者であったため脱退不可、よってエラー画面へ遷移') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm/resign_complete", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03011"
  end
  
  define_method('test: 脱退実行しようとしたが処理に失敗したため、エラー画面へ遷移') do
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "cmm/resign_complete", :id => 3
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03012"
  end
  
  define_method('test: 存在しないコミュニティへアクセスしようとしたため、エラー画面へ遷移') do
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "cmm/show", :id => 9999
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03013"
  end
end