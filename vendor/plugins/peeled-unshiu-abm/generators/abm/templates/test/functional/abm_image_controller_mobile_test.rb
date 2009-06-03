require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/functional/abm_image_controller_mobile_test.rb'

class AbmImageControllerMobileTest < ActionController::TestCase
  include AbmImageControllerMobileTestModule
  
  def setup
    super
    @controller = AbmImageController.new
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
