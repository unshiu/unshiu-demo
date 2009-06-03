require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/integration/base_user_config_controller_integration_test.rb'

class BaseUserConfigControllerIntegrationTest < ActionController::IntegrationTest
  include BaseUserConfigControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end