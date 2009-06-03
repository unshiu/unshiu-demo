require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/integration/base_signup_controller_integration_test.rb'

class BaseSignupControllerIntegrationTest < ActionController::IntegrationTest
  include BaseSignupControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end