require "#{File.dirname(__FILE__)}/../test_helper"

module MsgMessageControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: メッセージを自分自身にはおくれないのでエラー画面へ遷移') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "msg_message/new", :receivers => ["1"]
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-06001"
  end

  define_method('test: ゴミ箱にはいっている個別メーセージ閲覧で自分以外のメッセージを見ようとしたためエラー画面へ遷移') do 
    post "base_user/login", :login => "ten", :password => "test"
    
    post "msg_message/garbage_show", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-06002"
  end
  
  define_method('test: 編集権減のないユーザが編集画面を開こうとしたためエラー画面へ遷移') do 
    post "base_user/login", :login => "ten", :password => "test"
    
    post "msg_message/edit", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-06003"
  end
  
  define_method('test: メッセージIDを指定していないのでエラー画面へ遷移') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "msg_message/garbage_show"
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-06004"
  end
  
  define_method('test: リプライして返信しようとした際のリプライ元メッセージが自分のものでないのでエラー画面へ遷移') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "msg_message/reply", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-06005"
  end
  
  define_method('test: 作成者じゃないユーザが下書きを消そうとしたのでエラー画面へ遷移') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "msg_message/delete_draft_messages_confirm", :del => { 2 => nil }
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-06006"
  end
  
end