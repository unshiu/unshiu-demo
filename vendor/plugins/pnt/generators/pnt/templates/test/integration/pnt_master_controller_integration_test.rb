require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/integration/pnt_master_controller_integration_test.rb'

class PntMasterControllerIntegrationTest < ActionController::IntegrationTest
  include PntMasterControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end