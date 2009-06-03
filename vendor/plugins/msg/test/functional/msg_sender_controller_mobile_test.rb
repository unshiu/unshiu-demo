require File.dirname(__FILE__) + '/../test_helper'

module MsgSenderControllerMobileTestModule
  
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

  define_method('test: 送信メッセージ一覧を表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: 送信メッセージ個別詳細を表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show_mobile'
  end
  
  define_method('test: 送信メッセージ個別詳細を表示しようとするが、自分が送信したものではないのでエラー画面が表示する') do 
    login_as :quentin
    
    post :show, :id => 5
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 送信メッセージ削除確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 2
    assert_response :success
    assert_template 'delete_confirm_mobile'
  end
  
  define_method('test: 送信メッセージ削除確認画面を表示しようとするが、自分が送信したものではないのでエラー画面が表示する') do 
    login_as :aaron
    
    post :delete_confirm, :id => 1
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 送信メッセージの削除(ゴミ箱へうつす）を実行する') do 
    login_as :quentin
    
    post :delete, :id => 2
    assert_response :redirect
    assert_redirected_to :controller => 'msg_message', :action => 'delete_done'
    
    msg_sender = MsgSender.find_by_id(2)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ゴミ箱へはいってるかはステータスで判別
  end
  
  define_method('test: 送信メッセージの削除(ゴミ箱へうつす）しようとするが、自分が送信したものではないのでエラー画面が表示する') do 
    login_as :aaron
    
    post :delete, :id => 3
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 複数の送信メッセージ削除確認画面を表示する') do 
    login_as :quentin
    
    post :delete_messages_confirm, :del => { 1 => true, 2 => true } # id=1と2のメッセージを削除
    assert_response :success
    assert_template 'delete_messages_confirm_mobile'
  end
  
  define_method('test: 複数の送信メッセージ削除確認画面を表示しようとするが、自分が送信したものではないものが含まれているのでエラー画面が表示する') do 
    login_as :quentin
    
    post :delete_messages_confirm, :del => { 1 => true, 2 => true, 5 => true } # id=5はaaronが送信したもの
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 複数の送信メッセージ削除(ゴミ箱へうつす)を実行する') do 
    login_as :quentin
    
    # 事前チェック： 3も4もゴミ箱へははいってない
    before_msg_sender_3 = MsgSender.find_by_id(3)
    assert_not_equal before_msg_sender_3.trash_status, MsgMessage::TRASH_STATUS_GARBAGE 
  
    before_msg_sender_4 = MsgSender.find_by_id(4)
    assert_not_equal before_msg_sender_4.trash_status, MsgMessage::TRASH_STATUS_GARBAGE 
    
    post :delete_messages, :del => { 3 => true, 4 => true } # id=1と2のメッセージを削除
    assert_response :redirect
    assert_redirected_to :controller => 'msg_message', :action => 'delete_done'
    
    msg_sender_3 = MsgSender.find_by_id(3)
    assert_equal msg_sender_3.trash_status, MsgMessage::TRASH_STATUS_GARBAGE # ゴミ箱へはいってるかはステータスで判別
  
    msg_sender_4 = MsgSender.find_by_id(4)
    assert_equal msg_sender_4.trash_status, MsgMessage::TRASH_STATUS_GARBAGE 
  end
  
  define_method('test: 複数の送信メッセージ削除(ゴミ箱へうつす)を実行しようとするが、自分が送信したものではないものが含まれているのでエラー画面が表示する') do 
    login_as :aaron
    
    post :delete_messages, :del => { 1 => true, 2 => true, 5 => true } 
    assert_response :redirect # 対象外なのでエラーとなる
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ゴミ箱にある送信メッセージを元に戻す確認画面を表示する') do 
    login_as :aaron
    
    post :restore_confirm, :id => 6
    assert_response :success
    assert_template 'restore_confirm_mobile'
  end
  
  define_method('test: ゴミ箱にある送信メッセージを元に戻そうとするが、自分の送信メッセージではないためエラー画面を表示する') do 
    login_as :three
    
    post :restore_confirm, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ゴミ箱にある送信メッセージを元に戻す実処理をする') do 
    login_as :aaron
    
    post :restore, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'restore_done'
    
    msg_sender = MsgSender.find_by_id(6)
    assert_equal msg_sender.trash_status, nil # ステータスがnil=受信箱，送信箱，下書き箱のどこかに入っている状態 
  end
  
  define_method('test: ゴミ箱にある送信メッセージを元に戻そうとするが、自分の送信メッセージではないためエラー画面を表示する') do 
    login_as :quentin
    
    post :restore, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ゴミ箱にある送信メッセージを元に戻す処理をキャンセル') do 
    login_as :aaron
    
    post :restore, :id => 6, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'garbage_show'
    
    msg_sender = MsgSender.find_by_id(6)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE  # キャンセルしたのでステータスはそのまま
  end
  
  define_method('test: 送信メッセージをゴミ箱からも削除する確認画面を表示') do 
    login_as :aaron
    
    post :delete_completely_confirm, :id => 6
    assert_response :success
    assert_template 'delete_completely_confirm_mobile'
  end
  
  define_method('test: 送信メッセージをゴミ箱からも削除する確認画面を表示しようとするが、自分の送信メッセージではないためエラー画面を表示する') do 
    login_as :quentin
    
    post :delete_completely_confirm, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 送信メッセージをゴミ箱からも削除する実処理をする') do 
    login_as :aaron
    
    post :delete_completely, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'delete_completely_done'
    
    msg_sender = MsgSender.find_by_id(6)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_BURN # ステータスが完全削除
  end
  
  define_method('test: 送信メッセージをゴミ箱からも削除する実処理をしようとするが、自分の送信メッセージではないためエラー画面を表示する') do 
    login_as :quentin
    
    post :delete_completely, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 送信メッセージをゴミ箱からも削除する実処理をキャンセル') do 
    login_as :aaron
    
    post :delete_completely, :id => 6, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'garbage_show'
    
    msg_sender = MsgSender.find_by_id(6)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_GARBAGE  # キャンセルしたのでステータスはそのまま
  end
end
