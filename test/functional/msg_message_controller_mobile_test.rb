require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_message_controller_mobile_test.rb'

class MsgMessageControllerMobileTest < ActionController::TestCase
  include MsgMessageControllerMobileTestModule
  
  def setup
    @controller = MsgMessageController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
