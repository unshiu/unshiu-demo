require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/integration/base_favorite_controller_integration_test.rb'

class BaseFavoriteControllerIntegrationTest < ActionController::IntegrationTest
  include BaseFavoriteControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
end
