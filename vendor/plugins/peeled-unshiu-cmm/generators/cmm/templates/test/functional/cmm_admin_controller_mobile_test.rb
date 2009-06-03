require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/functional/cmm_admin_controller_mobile_test.rb'

class CmmAdminControllerMobileTest < ActionController::TestCase
  include CmmAdminControllerMobileTestModule
  
  def setup
    @controller = CmmAdminController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
