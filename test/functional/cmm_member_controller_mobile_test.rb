require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/functional/cmm_member_controller_mobile_test.rb'

class CmmMemberControllerMobileTest < ActionController::TestCase
  include CmmMemberControllerMobileTestModule
    
  def setup
    @controller = CmmMemberController.new
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
