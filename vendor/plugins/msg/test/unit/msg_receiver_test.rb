require File.dirname(__FILE__) + '/../test_helper'

module MsgReceiverTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :msg_messages
        fixtures :msg_receivers
      end
    end
  end
  
  # 関連付けのテスト
  def test_relation
    msg_receiver = MsgReceiver.find(1)
    assert_not_nil msg_receiver.base_user
    assert_not_nil msg_receiver.msg_message
  end
  
  # read_flag の文字列表現を取得するテスト
  def test_unread
    # 未読のとき
    msg_receiver = MsgReceiver.find(1)
    assert_not_equal 0, msg_receiver.unread.length
    
    # 既読のとき
    msg_receiver = MsgReceiver.find(2)
    assert_equal 0, msg_receiver.unread.length
  end
  
  # replied_flag の文字列表現を取得するテスト
  def test_replied
    # 返信済みのとき
    msg_receiver = MsgReceiver.find(2)
    assert_not_equal 0, msg_receiver.replied.length
    
    # 返信していないとき
    msg_receiver = MsgReceiver.find(1)
    assert_equal 0, msg_receiver.replied.length
  end
  
  # ゴミ箱に入れるテスト
  def test_into_trash_box
    msg_receiver = MsgReceiver.find(2)
    msg_receiver.into_trash_box
    assert_equal MsgMessage::TRASH_STATUS_GARBAGE, msg_receiver.trash_status
  end
  
  # まとめてゴミ箱に入れるテスト
  def test_delete_messages
    base_user = BaseUser.find(2)
    assert_equal 3, base_user.msg_receive_messages.count
    MsgReceiver.delete_messages(2, [9, 10])
    assert_equal 1, base_user.msg_receive_messages.count
  end

  # ゴミ箱から受信箱に戻すテスト
  def test_restore
    msg_receiver = MsgReceiver.find(3)
    msg_receiver.restore
    assert_equal MsgMessage::TRASH_STATUS_NONE, msg_receiver.trash_status
  end
  
  # ゴミ箱から削除するテスト
  def test_delete_completely
    msg_receiver = MsgReceiver.find(3)
    msg_receiver.delete_completely
    assert_equal MsgMessage::TRASH_STATUS_BURN, msg_receiver.trash_status
  end
  
  # メッセージを受信したことをメールで通知するテスト
  def test_notify_receiving_message
    msg_receiver = MsgReceiver.find(6)
    msg_receiver.notify_receiving_message
  end
  
  define_method('test: readはメッセージを既読にする') do 
    msg_receiver = MsgReceiver.find(1)
    msg_receiver.read_flag = false
    msg_receiver.save! # 事前処理: 未読にしておく
    
    msg_receiver.read
    
    assert_equal(msg_receiver.read_flag, true) # 既読にする
  end
  
end
