require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/tpc/test/integration/tpc_cmm_controller_integration_test.rb'

class TpcCmmControllerIntegrationTest < ActionController::IntegrationTest
  include TpcCmmControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end