require File.dirname(__FILE__) + '/../test_helper'

module MsgNotifyTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :msg_notifies
      end
    end
  end
  
  define_method('test: 通報メッセージを保存する') do 
    msg_notify = MsgNotify.new({:msg_message_id => 1, :comment => "問題があります"})
    assert_equal(msg_notify.save, true)
  end
  
  define_method('test: 通報メッセージは指定最大文字数を超えると保存できない') do 
    message = "あ" * (AppResources[:base][:body_max_length] + 1)
    msg_notify = MsgNotify.new({:msg_message_id => 1, :comment => message})
    assert_equal(msg_notify.save, false)
  end
  
end
