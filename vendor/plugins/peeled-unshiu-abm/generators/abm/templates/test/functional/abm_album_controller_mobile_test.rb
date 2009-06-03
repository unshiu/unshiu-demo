require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/functional/abm_album_controller_mobile_test.rb'

class AbmAlbumControllerMobileTest < ActionController::TestCase
  include AbmAlbumControllerMobileTestModule
  
  def setup
    super    
    @controller = AbmAlbumController.new
    setup_fixture_files
  end
  
  def teardown
    teardown_fixture_files
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
