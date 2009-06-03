require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MngSystemControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
      end
    end
  end
  
  define_method('test: 設定情報を表示する') do 
    login_as :quentin
    
    get :index
    assert_response :success
    assert_not_nil assigns(:system)
  end

  define_method('test: メール設定情報を表示する') do 
    login_as :quentin
    
    get :mail
    assert_response :success
  end
  
  define_method('test: データベース設定情報を表示する') do 
    login_as :quentin
    
    get :database
    assert_response :success
    assert_not_nil assigns(:system)
    assert_not_nil assigns(:db_adapter)
  end
  
  define_method('test: キャッシュ情報を表示する') do 
    login_as :quentin
    
    get :cache
    assert_response :success
    assert_not_nil assigns(:system)
  end
  
  define_method('test: インストール情報を確認する') do 
    login_as :quentin

    get :check
    assert_response :success
    assert_not_nil assigns(:system)
  end
  
end
