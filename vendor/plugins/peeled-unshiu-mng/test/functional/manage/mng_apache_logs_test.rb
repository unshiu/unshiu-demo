require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MngApacheLogsControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
      end
    end
  end
  
  define_method('test: ログ一覧を表示する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_not_nil assigns(:mng_apache_logs)
  end
  
  define_method('test: ログをダウンロードする') do 
    login_as :quentin

    get :download, :id => "mng_apache_log.txt"
    assert_response :success
  end
  
end

