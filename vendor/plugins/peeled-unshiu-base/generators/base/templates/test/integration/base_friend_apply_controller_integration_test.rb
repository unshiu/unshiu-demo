require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/integration/base_friend_apply_controller_integration_test.rb'

class BaseFriendApplyControllerIntegrationTest < ActionController::IntegrationTest
  include BaseFriendApplyControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end