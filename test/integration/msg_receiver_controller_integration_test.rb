require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/integration/msg_receiver_controller_integration_test.rb'

class MsgReceiverControllerIntegrationTest < ActionController::IntegrationTest
  include MsgReceiverControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end