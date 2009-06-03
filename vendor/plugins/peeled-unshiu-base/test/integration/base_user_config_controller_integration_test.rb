require "#{File.dirname(__FILE__)}/../test_helper"

module BaseUserConfigControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: メールアドレス変更処理を実行しようとするが既に有効なメールアドレスが設定されているのでエラーとなる') do 
    post "base_user_config/mail_reset", :id => 'activation-thirteen'
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01019"
  end
  
  define_method('test: メールアドレス変更処理を実行しようとするがアクティベーションコードが無効なのでエラー画面へ遷移') do 
    post "base_user_config/mail_reset", :id => '無効なアクティベーションコード'
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01020"
  end
  
end