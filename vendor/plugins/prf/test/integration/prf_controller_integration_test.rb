require "#{File.dirname(__FILE__)}/../test_helper"

module PrfControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :prf_profiles
        fixtures :prf_question_sets  
        fixtures :prf_question_set_partials  
        fixtures :prf_questions
        fixtures :prf_choices
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 質問の順番を下に移動する変更しようとするが不正な値をpostされたのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "quentin", :password => "test"

    post "manage/prf/move_question", :num => "-1", :type => "-1"
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "M-08001"
    
  end
    
end
