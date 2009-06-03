require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/integration/abm_image_controller_integration_test.rb'

class AbmImageControllerIntegrationTest < ActionController::IntegrationTest
  include AbmImageControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end