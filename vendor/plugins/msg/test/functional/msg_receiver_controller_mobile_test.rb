require File.dirname(__FILE__) + '/../test_helper'

module MsgReceiverControllerMobileTestModule
  
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

  define_method('test: 受信メッセージ一覧を表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: 受信メッセージ詳細を表示する') do 
    login_as :aaron
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show_mobile'
  end
  
  define_method('test: 受信メッセージ詳細を表示しようとするが、自分の受信メッセージではないのでエラー画面へ遷移する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 受信メッセージ削除の確認画面を表示する') do 
    login_as :aaron
    
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm_mobile'
  end
  
  define_method('test: 受信メッセージ削除の確認画面を表示しようとするが、自分の受信メッセージではないのでエラー画面へ遷移する') do 
    login_as :three
    
    post :delete_confirm, :id => 1
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 受信メッセージを削除（ゴミ箱へ移動）の実処理をする') do 
    login_as :aaron
    
    # 事前チェック：ステータスはゴミ箱ではない
    before_msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    assert_not_equal before_msg_receiver.trash_status, MsgMessage::TRASH_STATUS_GARBAGE
    
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'delete_done'
    
    after_msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    assert_equal after_msg_receiver.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
  end
  
  define_method('test: 受信メッセージを削除（ゴミ箱へ移動）の実処理をしようとするが、自分の受信メッセージではないのでエラー画面へ遷移する') do 
    login_as :quentin
        
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 複数の受信メッセージ削除の確認画面を表示する') do 
    login_as :aaron
    
    post :delete_messages_confirm, :del => { 1 => true, 2 => true }
    assert_response :success
    assert_template 'delete_messages_confirm_mobile'
  end
  
  define_method('test: 複数の受信メッセージ削除の確認画面を表示しようとするが1件も選択されていない場合のテスト') do 
    login_as :aaron
    
    post :delete_messages_confirm
    assert_response :redirect
    assert_redirected_to :action => 'list' # 一覧へ戻される
  end
  
  define_method('test: 複数の受信メッセージ削除の確認画面を表示しようとするが、自分の受信メッセージじゃないものが含まれているのでエラー画面へ遷移する') do 
    login_as :aaron
    
    post :delete_messages_confirm, :del => { 1 => true, 5 => true } # 5 は quentinの受信メッセージ
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 複数の受信メッセージ削除（ゴミ箱へ移動）の実処理をする') do 
    login_as :aaron
    
    post :delete_messages, :del => { 1 => true, 2 => true }
    assert_response :redirect 
    assert_redirected_to :action => 'delete_done'
    
    msg_receiver_a = MsgReceiver.find(:first, :conditions => ['base_user_id = 2 and msg_message_id = 1'])
    assert_equal msg_receiver_a.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
    
    msg_receiver_b = MsgReceiver.find(:first, :conditions => ['base_user_id = 2 and msg_message_id = 1'])
    assert_equal msg_receiver_b.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
  end
  
  define_method('test: ゴミ箱から元に戻す確認画面を表示する') do 
    login_as :quentin
    
    post :restore_confirm, :id => 7 # 7は既にゴミ箱にはいってる状態
    assert_response :success
    assert_template 'restore_confirm_mobile'
  end
  
  define_method('test: ゴミ箱から元に戻す確認画面を表示しようとするが、自分の受信メッセージじゃないのでエラー画面へ遷移する') do 
    login_as :aaron
    
    post :restore_confirm, :id => 7 # 7は既にゴミ箱にはいってる状態
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ゴミ箱から元に戻す実処理をする') do 
    login_as :quentin
    
    post :restore, :id => 7 # 7は既にゴミ箱にはいってる状態
    assert_response :redirect 
    assert_redirected_to :action => 'restore_done'
    
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = 1 and msg_message_id = 7'])
    assert_equal msg_receiver.trash_status, nil # ステータスはnil=受信箱，送信箱，下書き箱のどこかに入っている状態
  end
  
  define_method('test: ゴミ箱から元に戻す実処理をしようとするが、自分の受信メッセージじゃないものでエラー画面へ遷移する') do 
    login_as :three
    
    post :restore, :id => 7 # 7は既にゴミ箱にはいってる状態
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ゴミ箱からも削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_completely_confirm, :id => 5
    assert_response :success
    assert_template 'delete_completely_confirm_mobile'
  end
  
  define_method('test: ゴミ箱からも削除する確認画面を表示しようとするが、自分の受信メッセージじゃないものでエラー画面へ遷移する') do 
    login_as :three
    
    post :delete_completely_confirm, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ゴミ箱からも削除する実処理をする') do 
    login_as :quentin
    
    post :delete_completely, :id => 7
    assert_response :redirect 
    assert_redirected_to :action => 'delete_completely_done'
    
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = 1 and msg_message_id = 5'])
    assert_equal msg_receiver.trash_status, MsgMessage::TRASH_STATUS_BURN # ステータスが完全削除済みとなる
  end
  
  define_method('test: ゴミ箱からも削除する実処理をしようとするが、自分の受信メッセージじゃないものでエラー画面へ遷移する') do 
    login_as :aaron
    
    post :delete_completely, :id => 7
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
end
