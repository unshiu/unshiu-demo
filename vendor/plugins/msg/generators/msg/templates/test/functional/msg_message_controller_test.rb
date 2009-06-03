require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_message_controller_test.rb'

class MsgMessageControllerTest < ActionController::TestCase
  include MsgMessageControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
