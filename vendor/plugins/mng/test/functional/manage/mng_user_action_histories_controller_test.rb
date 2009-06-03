require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MngUserActionHistoriesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mng_user_action_histories
      end
    end
  end
  
  define_method('test: 管理者画面操作履歴一覧を表示する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_not_nil assigns(:mng_user_action_histories)
  end
  
end

