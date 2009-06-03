require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/integration/prf_controller_integration_test.rb'

class PrfControllerIntegrationTest < ActionController::IntegrationTest
  include PrfControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end
