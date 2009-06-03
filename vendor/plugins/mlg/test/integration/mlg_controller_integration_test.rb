require "#{File.dirname(__FILE__)}/../test_helper"

module MlgControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mlg_deliveries
        fixtures :mlg_magazines
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: メールマガジン削除確認画面を表示しようとするが、配信済みなので削除できない') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "manage/mlg/delete_confirm", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "M-05001"
    
  end

end