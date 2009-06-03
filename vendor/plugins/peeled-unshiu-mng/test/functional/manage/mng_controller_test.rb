require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MngControllerTestModule
  
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

  define_method('test: 管理者権限で管理画面へアクセスする') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
  end
  
  define_method('test: パスワードが標準であった場合は管理画面トップでその旨を表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_match(/管理者パスワードがシステム標準/, @response.body)
  end

  define_method('test: パスワードが標準でなければ管理画面トップでその旨は表示されない') do
    user = BaseUser.find(1)
    user.password = "securitypassword"
    user.save!
     
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_no_match(/管理者パスワードがシステム標準/, @response.body)
  end
  
  define_method('test: 管理者でないユーザは管理画面へアクセスできない') do 
    login_as :ten
    
    post :index
    assert_response :redirect 
    assert_redirected_to :controller => '/base', :action => 'index'
  end
  
  define_method('test: 管理者権限で管理画面へアクセスすると記録が残る') do 
    login_as :quentin
    
    assert_difference 'MngUserActionHistory.count', 1 do
      post :index
      assert_response :success
      assert_template 'index'
    end
  end
  
  define_method('test: ログアウト処理をする') do 
    login_as :quentin
    
    # 事前条件:セッションにログイン情報はもっている
    assert_equal @request.session[:base_user], 1
    
    post :logout
    assert_response :redirect 
    assert_redirected_to :controller => 'manage/mng', :action => 'index'
    
    assert_equal @request.session[:base_user], nil # ログアウトしたのでセッションからID情報が消えている
  end
  
end
