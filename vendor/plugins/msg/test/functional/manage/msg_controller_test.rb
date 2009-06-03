require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MsgControllerTestModule
    
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
      end
    end
  end

  define_method('test: メッセージ管理トップページを表示する') do 
    login_as :quentin
  
    post :index
    assert_response :success
    assert_template 'list' # 表示されるのはlistページ
  end

  define_method('test: メッセージ一覧を表示する') do 
    login_as :quentin
  
    post :list
    assert_response :success
    assert_template 'list' 
  end

  define_method('test: 送信されたメッセージ一覧を表示する') do 
    login_as :quentin
  
    post :sent_list
    assert_response :success
    assert_template 'sent_list' 
  end

  define_method('test: 通報されたメッセージ一覧を表示する') do 
    login_as :quentin
  
    post :notify_list
    assert_response :success
    assert_template 'notify_list' 
  end

  define_method('test: メッセージ個別を表示する') do 
    login_as :quentin
  
    post :show, :id => 1
    assert_response :success
    assert_template 'show' 
  end

  define_method('test: メッセージ削除確認画面を表示する') do 
    login_as :quentin
  
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm' 
  end

  define_method('test: メッセージ削除を実行する') do 
    login_as :quentin
  
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  
    msg_message = MsgMessage.find_by_id(1)
    assert_nil msg_message # 削除されている
  end

  define_method('test: メッセージ削除を実行をキャンセルする') do 
    login_as :quentin
  
    post :delete, :id => 1, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    msg_message = MsgMessage.find_by_id(1)
    assert_not_nil msg_message # 削除されていない
  end

  define_method('test: 管理者がメッセージを新規作成する画面を表示する') do 
    login_as :quentin
  
    post :new, :id => 1
    assert_response :success
    assert_template 'new'
  end

  define_method('test: 管理者がユーザ全員宛のメッセージを新規作成する画面を表示する') do 
    login_as :quentin
  
    post :new
    assert_response :success
    assert_template 'new'
  end

  define_method('test: 管理者がメッセージを新規作成する確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :id => 1, :message => { :title => 'test title', :body => 'test body'}
    assert_response :success
    assert_template 'confirm'
  end

  define_method('test: 管理者がユーザ全員宛のメッセージを新規作成する確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :message => { :title => 'test title', :body => 'test body'}
    assert_response :success
    assert_template 'confirm'
  end

  define_method('test: 管理者がメッセージを新規作成する確認画面を表示しようとするが、タイトルが未入力なので作成ページに戻される') do 
    login_as :quentin
  
    post :confirm, :id => 1, :message => { :title => '', :body => 'test body'}
    assert_response :success
    assert_template 'new'
  end

  define_method('test: 管理者がメッセージを新規作成実行をする') do 
    login_as :quentin
  
    # 事前チェック：作成後にチェックするメッセージは作成されてない
    msg_message = MsgMessage.find(:first, :conditions => ["title = '管理者がメッセージを新規作成実行をする'"])
    assert_nil msg_message 
  
    post :create, :id => 1, :message => { :title => '管理者がメッセージを新規作成実行をする', :body => 'test body'}
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  
    msg_message = MsgMessage.find(:first, :conditions => ["title = '管理者がメッセージを新規作成実行をする'"])
    assert_not_nil msg_message # 作成されている
  end

  define_method('test: 管理者がメッセージを新規作成実行をキャンセルする') do 
    login_as :quentin
  
    post :create, :id => 1, 
                  :cancel => 'true',
                  :message => { :title => '管理者がメッセージを新規作成実行をキャンセルする', :body => 'test body'}
                  assert_response :success
                  assert_template 'new'
  
    msg_message = MsgMessage.find(:first, :conditions => ["title = '管理者がメッセージを新規作成実行をキャンセルする'"])
    assert_nil msg_message # キャンセルしたので作成されていない
  end

  define_method('test: 管理者がユーザ全員宛のメッセージを新規作成実行する') do 
    # TODO: BackgrounDRbがかかわってくるのであとで
  end
end
