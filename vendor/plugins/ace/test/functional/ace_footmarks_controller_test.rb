require File.dirname(__FILE__) + '/../test_helper'

module AceFootmarksControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :ace_footmarks
      end
    end
  end
  
  define_method('test: 自分が踏まれた足跡を表示する') do 
    login_as :quentin
  
    get :index
    assert_response :success
    assert_not_nil assigns(:footmarks)
  end
  
end
