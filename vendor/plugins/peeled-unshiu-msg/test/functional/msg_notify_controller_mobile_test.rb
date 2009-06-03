require File.dirname(__FILE__) + '/../test_helper'

module MsgNotifyControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
      end
    end
  end

  # メッセージ通報新規作成
  def test_new
    login_as :aaron 
    
    post :new, :id => 1
    assert_response :success
    assert_template 'new_mobile'    
  end
  
  # 自分が受け取ったもしくメッセージ通報の新規作成ができるように
  def test_new_non_user
    login_as :ten
    
    post :new, :id => 1
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  # メッセージ通報確認ページ
  def test_confirm
    login_as :aaron 
    
    post :confirm, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :success
    assert_template 'confirm_mobile'
    
    # commentが未記入だとnew画面へ戻る
    post :confirm, :id => 1, :notify => { :comment => '' }
    assert_response :success
    assert_template 'new_mobile'
  end
  
  # 自分が受け取ったもしくメッセージしかうけつけない
  def test_confirm_non_user
    login_as :five
    
    post :confirm, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  # メッセージ通報新規作成ページ
  def test_create
    login_as :aaron 
    
    post :create, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :redirect
    assert_redirected_to :action => 'done'
    
    # 作成されているか確認
    msg_notify = MsgNotify.find(:first, :conditions => [' msg_message_id = ? ', 1], :order => 'created_at desc')
    assert_not_nil msg_notify
    assert_equal msg_notify.comment, 'test notify'
  end
  
  # 自分が受け取ったもしくメッセージしかうけつけない
  def test_create_non_user
    login_as :five
    
    post :create, :id => 1, :notify => { :comment => 'test notify' }
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
end
