require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/mlg/test/integration/mlg_controller_integration_test.rb'

class MlgControllerIntegrationTest < ActionController::IntegrationTest
  include MlgControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end

end