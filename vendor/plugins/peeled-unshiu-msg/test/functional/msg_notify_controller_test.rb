require File.dirname(__FILE__) + '/../test_helper'

module MsgNotifyControllerTestModule
  
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

  define_method('test: new はメッセージ通報新規作成画面を表示する') do 
    login_as :aaron 
    
    post :new, :id => 1
    assert_response :success
    assert_template 'new'    
  end

  define_method('test: new では自分が受け取ったメッセージでない場合、エラー画面を表示する') do 
    login_as :ten
    
    post :new, :id => 1
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: confirm では通報メッセージを確認する') do 
    login_as :aaron 
    
    post :confirm, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: confirm では通報メッセージのvalidateを確認し問題があれば new 画面を表示する') do 
    login_as :aaron 
    
    # commentが未記入だとnew画面へ戻る
    post :confirm, :id => 1, :notify => { :comment => '' }
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: confirm では自分が受け取ったメッセージでない場合、エラー画面を表示する') do 
    login_as :five
    
    post :confirm, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: create はメッセージの通報を実行する') do 
    login_as :aaron 
    
    post :create, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :redirect
    assert_redirected_to :controller => :msg_message, :action => 'index'
    assert_not_nil(flash[:notice])
    
    # 作成されているか確認
    msg_notify = MsgNotify.find(:first, :conditions => [' msg_message_id = ? ', 1], :order => 'created_at desc')
    assert_not_nil msg_notify
    assert_equal msg_notify.comment, 'test notify'
  end
  
  define_method('test: create は cancel された場合はメッセージの通報の実行をしない') do 
    login_as :aaron 
    
    post :create, :id => 1, :notify => { :comment => 'test create cancel notify' }, :cancel => "true"
    assert_response :success
    assert_template 'new'
    assert_nil(flash[:notice])
    
    # 作成されていないか
    msg_notify = MsgNotify.find(:first, :conditions => [" comment = 'test create cancel notify' "])
    assert_nil msg_notify
  end
  
  define_method('test: create は自分が受け取ったメッセージの以外の通報を実行をしようとするとエラー画面を表示する') do 
    login_as :five
    
    post :create, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
end
