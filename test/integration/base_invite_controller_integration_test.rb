require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/integration/base_invite_controller_integration_test.rb'

class BaseInviteControllerIntegrationTest < ActionController::IntegrationTest
  include BaseInviteControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end