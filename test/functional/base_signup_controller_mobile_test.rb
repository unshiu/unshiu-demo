require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_signup_controller_mobile_test.rb'

class BaseSignupControllerMobileTest < ActionController::TestCase
  include BaseSignupControllerMobileTestModule
  
  def setup
    @controller = BaseSignupController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
