require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/integration/msg_message_controller_integration_test.rb'

class MsgMessageControllerIntegrationTest < ActionController::IntegrationTest
  include MsgMessageControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end