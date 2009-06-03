require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/functional/abm_image_controller_test.rb'

class AbmImageControllerTest < ActionController::TestCase
  include AbmImageControllerTestModule
  
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
