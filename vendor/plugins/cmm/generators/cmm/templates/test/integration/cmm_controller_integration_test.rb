require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/integration/cmm_controller_integration_test.rb'

class CmmControllerIntegrationTest < ActionController::IntegrationTest
  include CmmControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end