require "#{File.dirname(__FILE__)}/../test_helper"

module PntMasterControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :pnt_history_summaries
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: アクセス権限のないユーザがアルバム画像のコメントをみようとしたのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "quentin", :password => "test"

    post "manage/pnt_master/delete_confirm", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "M-07001"
  end
  
end