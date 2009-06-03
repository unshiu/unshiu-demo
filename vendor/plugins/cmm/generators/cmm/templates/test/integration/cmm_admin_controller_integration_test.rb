require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/integration/cmm_admin_controller_integration_test.rb'

class CmmAdminControllerIntegrationTest < ActionController::IntegrationTest
  include CmmAdminControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end