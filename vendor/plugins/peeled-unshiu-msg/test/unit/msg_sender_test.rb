require File.dirname(__FILE__) + '/../test_helper'

module MsgSenderTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :msg_messages
        fixtures :msg_senders
      end
    end
  end
  
  # 関連付けのテスト
  def test_relation
    msg_sender = MsgSender.find(1)
    assert_not_nil msg_sender.base_user
    assert_not_nil msg_sender.msg_message
  end

  # ゴミ箱に入れるテスト
  def test_into_trash_box
    msg_sender = MsgSender.find(1)
    msg_sender.into_trash_box
    assert_equal MsgMessage::TRASH_STATUS_GARBAGE, msg_sender.trash_status
  end

  # まとめてゴミ箱に入れるテスト
  def test_delete_messages
    base_user = BaseUser.find(1)
    assert_equal 3, base_user.msg_send_messages.count
    MsgSender.delete_messages(1, [9, 10])
    assert_equal 1, base_user.msg_send_messages.count
  end
  
  # ゴミ箱から送信箱に戻すテスト
  def test_restore
    msg_sender = MsgSender.find(2)
    msg_sender.restore
    assert_equal MsgMessage::TRASH_STATUS_NONE, msg_sender.trash_status
  end
  
  # ゴミ箱から削除するテスト
  def test_delete_completely
    msg_sender = MsgSender.find(2)
    msg_sender.delete_completely
    assert_equal MsgMessage::TRASH_STATUS_BURN, msg_sender.trash_status
  end
end
