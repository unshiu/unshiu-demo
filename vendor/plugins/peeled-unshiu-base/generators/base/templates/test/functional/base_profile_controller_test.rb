require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_profile_controller_test.rb'

class BaseProfileControllerTest < ActionController::TestCase
  include BaseProfileControllerTestModule
  
  def setup
    setup_fixture_files
    
    @controller = BaseProfileController.new
    super
  end
  
  def teardown
    teardown_fixture_files
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
