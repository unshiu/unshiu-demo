require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_profile_controller_mobile_test.rb'

class BaseProfileControllerMobileTest < ActionController::TestCase
  include BaseProfileControllerMobileTestModule
  
  def setup
    @controller = BaseProfileController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
