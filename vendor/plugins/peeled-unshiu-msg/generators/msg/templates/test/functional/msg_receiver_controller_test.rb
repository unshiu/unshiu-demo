require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_receiver_controller_test.rb'

class MsgReceiverControllerTest < ActionController::TestCase
  include MsgReceiverControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
