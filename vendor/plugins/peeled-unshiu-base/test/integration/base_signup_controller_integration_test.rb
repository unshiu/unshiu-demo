require "#{File.dirname(__FILE__)}/../test_helper"

module BaseSignupControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_friends
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 利用規約同意画面を表示しようとするがアクティベーションコードが無効なのでエラー画面へ遷移') do 
    post "base_signup/ask_agreement", :id => '無効なアクティベーションコード'
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01018"
  end
  
  
  define_method('test: ユーザを削除しようとするが管理者なのでエラー画面へ遷移') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_signup/quit_confirm"
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01022"
  end
end