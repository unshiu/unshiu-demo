require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_notify_controller_test.rb'

class MsgNotifyControllerTest < ActionController::TestCase
  include MsgNotifyControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
