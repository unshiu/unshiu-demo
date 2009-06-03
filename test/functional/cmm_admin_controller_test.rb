require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/functional/cmm_admin_controller_test.rb'

class CmmAdminControllerTest < ActionController::TestCase
  include CmmAdminControllerTestModule
  
  def setup
    setup_fixture_files
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
