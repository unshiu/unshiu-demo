require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/integration/abm_album_controller_integration_test.rb'

class AbmAlbumControllerIntegrationTest < ActionController::IntegrationTest
  include AbmAlbumControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end