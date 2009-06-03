require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MlgControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mlg_deliveries
        fixtures :mlg_magazines
      end
    end
  end

  define_method('test: メールマガジン新規作成画面を表示する') do 
    login_as :quentin
  
    post :new, :id => 1
    assert_response :success
    assert_template 'new'
  end

  define_method('test: メールマガジン新規作成確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :mlg_magazine => { :title => 'メルマガタイトル', :body => '本文' }
    assert_response :success
    assert_template 'confirm'
  end

  define_method('test: メールマガジン新規作成確認画面を表示しようとするがタイトルが未入力のため作成画面を表示') do 
    login_as :quentin
  
    post :confirm, :mlg_magazine => { :title => '', :body => '本文' }
    assert_response :success
    assert_template 'new'
  end

  define_method('test: メールマガジン新規作成実行をする') do 
    login_as :quentin
  
    post :create, :mlg_magazine => { :title => 'メルマガタイトル', :body => '本文' }
    assert_response :redirect
    assert_redirected_to :action => 'list'
  
    # 正常に作成されている
    mlg_magazine = MlgMagazine.find(:first, :conditions => [" title = 'メルマガタイトル'"])
    assert_equal mlg_magazine.title, 'メルマガタイトル'
    assert_equal mlg_magazine.body, '本文' 
  end

  define_method('test: メールマガジン新規作成実行をするが、なぜがタイトルが未入力のため作成画面へ戻る') do 
    login_as :quentin
  
    post :create, :mlg_magazine => { :title => '', :body => '本文' }
    assert_response :redirect
    assert_redirected_to :action => 'new'
  end

  define_method('test: メールマガジン新規作成実行のキャンセル') do 
    login_as :quentin
  
    post :create, :mlg_magazine => { :title => 'メルマガタイトル', :body => '本文' }, :cancel => true
    assert_response :success
    assert_template 'new'
  
    # キャンセルしたので作成はされていない
    mlg_magazine = MlgMagazine.find(:first, :conditions => [" title = 'メルマガタイトル'"])
    assert_nil mlg_magazine
  end

  define_method('test: メールマガジン個別詳細を確認する') do 
    login_as :quentin
  
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end

  define_method('test: メールマガジン一覧を表示する') do 
    login_as :quentin
  
    post :list, :id => 1
    assert_response :success
    assert_template 'list'
  end

  define_method('test: メールマガジン削除確認画面を表示する') do 
    login_as :quentin
  
    post :delete_confirm, :id => 5
    assert_response :success
    assert_template 'delete_confirm'
  end

  define_method('test: メールマガジン削除確認画面を表示しようとするが、配信済みなので削除できない') do 
    login_as :quentin
  
    post :delete_confirm, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end

  define_method('test: メールマガジン削除を実行する') do 
    login_as :quentin
  
    post :delete, :mlg_magazine => { :id => 5 }
    assert_response :redirect
    assert_redirected_to :action => 'list'
  
    # 削除されている
    mlg_magazine = MlgMagazine.find_by_id(5)
    assert_nil mlg_magazine
  end

  define_method('test: メールマガジン削除を実行しようとするが、配信済みなので削除できない') do 
    login_as :quentin
  
    post :delete, :mlg_magazine => { :id => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'error'
  
    # 削除されていない
    mlg_magazine = MlgMagazine.find_by_id(1)
    assert_not_nil mlg_magazine
  end

  define_method('test: メールマガジン削除を実行をキャンセル') do 
    login_as :quentin
  
    post :delete, :mlg_magazine => { :id => 5 }, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => 'list'
  
    # キャンセルされたので削除されていない
    mlg_magazine = MlgMagazine.find_by_id(5)
    assert_not_nil mlg_magazine
  end
end
