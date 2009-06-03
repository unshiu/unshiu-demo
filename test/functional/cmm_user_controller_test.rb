require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/functional/cmm_user_controller_test.rb'

class CmmUserControllerTest < ActionController::TestCase
  include CmmUserControllerTestModule
  
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
