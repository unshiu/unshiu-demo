require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/integration/base_friend_controller_integration_test.rb'

class BaseFriendControllerIntegrationTest < ActionController::IntegrationTest
  include BaseFriendControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end