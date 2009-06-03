require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_notify_controller_mobile_test.rb'

class MsgNotifyControllerMobileTest < ActionController::TestCase
  include MsgNotifyControllerMobileTestModule
  
  def setup
    @controller = MsgNotifyController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
