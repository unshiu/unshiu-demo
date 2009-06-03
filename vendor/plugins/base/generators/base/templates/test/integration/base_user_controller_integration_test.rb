require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/integration/base_user_controller_integration_test.rb'

class BaseUserControllerIntegrationTest < ActionController::IntegrationTest
  include BaseUserControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end