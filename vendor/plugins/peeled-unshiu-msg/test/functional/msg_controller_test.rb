require File.dirname(__FILE__) + '/../test_helper'

module MsgControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
      end
    end
  end
  
  # msg_controllerが直接使われることは現状存在せず、
  # あくまでメッセージ系のコントローラの親クラスとして存在してるのでテストはいらない
  
  def test_true
    assert true
  end
end
