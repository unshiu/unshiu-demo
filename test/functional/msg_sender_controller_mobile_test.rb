require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_sender_controller_mobile_test.rb'

class MsgSenderControllerMobileTest < ActionController::TestCase
  include MsgSenderControllerMobileTestModule
  
  def setup
    @controller = MsgSenderController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
