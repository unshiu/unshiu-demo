require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/functional/abm_album_controller_test.rb'

class AbmAlbumControllerTest < ActionController::TestCase
  include AbmAlbumControllerTestModule
  
  def setup
    super    
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
  