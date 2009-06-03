require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MngUserActionHistoryArchivesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mng_user_action_histories
        fixtures :mng_user_action_history_archives
      end
    end
  end
  
  define_method('test: 一覧を表示する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_not_nil assigns(:mng_user_action_history_archives)
  end

  define_method('test: 個別ファイルをダウンロードする') do 
    login_as :quentin

    get :download, :id => 1
    assert_response :success
  end
  
end
