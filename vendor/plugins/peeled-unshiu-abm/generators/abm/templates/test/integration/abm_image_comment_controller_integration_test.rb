require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/integration/abm_image_comment_controller_integration_test.rb'

class AbmImageCommentControllerIntegrationTest < ActionController::IntegrationTest
  include AbmImageCommentControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end