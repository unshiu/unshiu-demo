require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_receiver_controller_mobile_test.rb'

class MsgReceiverControllerMobileTest < ActionController::TestCase
  include MsgReceiverControllerMobileTestModule
  
  def setup
    @controller = MsgReceiverController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
