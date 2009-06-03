require File.dirname(__FILE__) + '/../test_helper'

module MsgReceiverControllerTestModule
  
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
        
        use_transactional_fixtures = false
      end
    end
  end
  
  define_method('test: 受信メッセージ詳細を表示する') do 
    login_as :aaron
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["received_count"])
    assert_not_nil(assigns["garbage_count"])
    
    assert_not_nil(assigns["next_message"])
    assert_nil(assigns["prev_message"])
    
  end
  
  define_method('test: show は退会したユーザからの受信メッセージ詳細を表示することができる') do 
    login_as :aaron
    
    post :show, :id => 13 # 退会したユーザのメッセージ
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["received_count"])
    assert_not_nil(assigns["garbage_count"])
  end
  
  define_method('test: 選択された受信メッセージをゴミ箱へ移す') do 
    login_as :aaron
    
    post :delete_messages_remote, :message_ids => [ "1", "2" ]
    assert_response :success
    assert_rjs :visual_effect, :highlight, "callback_function_message"    
    
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    assert_equal msg_receiver.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
    
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 2])
    assert_equal msg_receiver.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
  end
  
  define_method('test: read_messages_remote は選択された受信メッセージを既読にする') do 
    login_as :aaron

    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    msg_receiver.read_flag = false
    msg_receiver.save
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 2])
    msg_receiver.read_flag = false
    msg_receiver.save

    post :read_messages_remote, :message_ids => [ "1", "2" ]
    assert_response :success
    assert_rjs :visual_effect, :highlight, "callback_function_message"    

    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    assert_equal msg_receiver.read_flag, true

    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 2])
    assert_equal msg_receiver.read_flag, true
  end
   
  define_method('test: unread_messages_remote は選択された受信メッセージを未読にする') do 
    login_as :aaron

    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    msg_receiver.read_flag = true
    msg_receiver.save
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 2])
    msg_receiver.read_flag = true
    msg_receiver.save

    post :unread_messages_remote, :message_ids => [ "1", "2" ]
    assert_response :success
    assert_rjs :visual_effect, :highlight, "callback_function_message"    

    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    assert_equal msg_receiver.read_flag, false

    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 2])
    assert_equal msg_receiver.read_flag, false
  end


  define_method('test: delete は受信メッセージを削除（ゴミ箱へ移動）の実処理をする') do 
    login_as :aaron

    # 事前チェック：ステータスはゴミ箱ではない
    before_msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    assert_not_equal before_msg_receiver.trash_status, MsgMessage::TRASH_STATUS_GARBAGE

    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :controller => 'msg_message', :action => 'index'
    assert_not_nil(flash[:notice])
    
    after_msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = ? and msg_message_id = ?', 2, 1])
    assert_equal after_msg_receiver.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
  end

  define_method('test: 受信メッセージを削除（ゴミ箱へ移動）の実処理をしようとするが、自分の受信メッセージではないのでエラー画面へ遷移する') do 
    login_as :quentin

    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: delete_completely_confirm はゴミ箱からも削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_completely_confirm, :id => 5
    assert_response :success
    assert_template 'delete_completely_confirm'
    
    assert_not_nil(assigns["message"])
    assert_not_nil(assigns["received_count"])
    assert_not_nil(assigns["sent_count"])
    assert_not_nil(assigns["draft_count"])
    assert_not_nil(assigns["garbage_count"])
  end
  
  define_method('test: delete_completely_confirm は自分の受信メッセージじゃないメッセージを指定された場合はエラー画面へ遷移する') do 
    login_as :three
    
    post :delete_completely_confirm, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: delete_completely ゴミ箱からも削除する実処理をする') do 
    login_as :quentin
    
    post :delete_completely, :id => 7
    assert_response :redirect 
    assert_redirected_to :action => 'garbage_list'
    
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = 1 and msg_message_id = 5'])
    assert_equal msg_receiver.trash_status, MsgMessage::TRASH_STATUS_BURN # ステータスが完全削除済みとなる
  end
  
  define_method('test: delete_completely 自分の受信メッセージじゃないメッセージを指定された場合でエラー画面へ遷移する') do 
    login_as :aaron
    
    post :delete_completely, :id => 7
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: restore はゴミ箱から元に戻す実処理をする') do 
    login_as :quentin
    
    post :restore, :id => 7 # 7は既にゴミ箱にはいってる状態
    assert_response :redirect 
    assert_redirected_to :controller => 'msg_message', :action => 'garbage_list'
    
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = 1 and msg_message_id = 7'])
    assert_equal msg_receiver.trash_status, nil # ステータスはnil=受信箱，送信箱，下書き箱のどこかに入っている状態
  end
  
  define_method('test: restore を自分の受信メッセージじゃないもので実行しようとするとエラー画面へ遷移する') do 
    login_as :three
    
    post :restore, :id => 7 # 7は既にゴミ箱にはいってる状態
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
end
