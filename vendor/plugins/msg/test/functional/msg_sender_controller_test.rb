require File.dirname(__FILE__) + '/../test_helper'

module MsgSenderControllerTestModule
  
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

  define_method('test: 送信メッセージ一覧を表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list'
    
    assert_not_nil(assigns["received_count"])
    assert_not_nil(assigns["sent_count"])
    assert_not_nil(assigns["draft_count"])
    assert_not_nil(assigns["garbage_count"])
  end
  
  define_method('test: 送信メッセージ詳細を表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["next_message"])
    assert_nil(assigns["prev_message"]) # id = 1 より前のものはないので
    
  end
  
  define_method('test: delete_messages_remote は選択された受信メッセージをゴミ箱へ移す') do 
    login_as :quentin
    
    post :delete_messages_remote, :message_ids => [ "1", "2" ]
    assert_response :success
    assert_rjs :visual_effect, :highlight, "callback_function_message"    
    
    msg_sender = MsgSender.find_by_msg_message_id(1)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
    
    msg_sender = MsgSender.find_by_msg_message_id(1)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
  end
    
  define_method('test: delete_messages_remote は自分が送信したものではないのでエラーをメッセージに表示する') do 
    login_as :aaron
    
    post :delete_messages_remote, :message_ids => [ "1", "2" ]
    assert_response :success
    assert_rjs :visual_effect, :highlight, "callback_function_message"
    
    msg_sender = MsgSender.find_by_msg_message_id(1)
    assert_not_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱

    msg_sender = MsgSender.find_by_msg_message_id(1)
    assert_not_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ステータスはゴミ箱
  end
  
  define_method('test: delete_completely_confirm は送信メッセージをゴミ箱からも削除する確認画面を表示する') do 
    login_as :aaron

    post :delete_completely_confirm, :id => 6
    assert_response :success
    assert_template 'delete_completely_confirm'
    
    assert_not_nil(assigns["message"])
    assert_not_nil(assigns["received_count"])
    assert_not_nil(assigns["sent_count"])
    assert_not_nil(assigns["draft_count"])
    assert_not_nil(assigns["garbage_count"])
  end
  
  define_method('test: delete_completely_confirm は自分の送信メッセージではなければエラー画面を表示する') do 
    login_as :quentin
    
    post :delete_completely_confirm, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: delete_completely は送信メッセージをゴミ箱からも削除する実処理をする') do 
    login_as :aaron
    
    post :delete_completely, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'garbage_list'
    assert_not_nil(flash[:notice])
    
    msg_sender = MsgSender.find_by_id(6)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_BURN # ステータスが完全削除
  end
  
  define_method('test: delete_completely は自分の送信メッセージではなければエラー画面を表示する') do 
    login_as :quentin
    
    post :delete_completely, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: delete_completely はキャンセルボタンを押すと実処理をキャンセルする') do 
    login_as :aaron
    
    post :delete_completely, :id => 6, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'garbage_show'
    
    msg_sender = MsgSender.find_by_id(6)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE  # キャンセルしたのでステータスはそのまま
  end
  
  define_method('test: restore はゴミ箱にある送信メッセージを元に戻す実処理をする') do 
    login_as :aaron
    
    post :restore, :id => 6
    assert_response :redirect 
    assert_redirected_to :controller => 'msg_message', :action => 'garbage_list'
    
    msg_sender = MsgSender.find_by_id(6)
    assert_equal msg_sender.trash_status, nil # ステータスがnil=受信箱，送信箱，下書き箱のどこかに入っている状態 
  end
  
  define_method('test: restore は自分の送信メッセージではないためエラー画面を表示する') do 
    login_as :quentin
    
    post :restore, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
end
