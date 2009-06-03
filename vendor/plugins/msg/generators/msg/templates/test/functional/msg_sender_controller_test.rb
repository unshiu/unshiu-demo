require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_sender_controller_test.rb'

class MsgSenderControllerTest < ActionController::TestCase
  include MsgSenderControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
