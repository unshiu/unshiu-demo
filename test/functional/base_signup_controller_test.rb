require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_signup_controller_test.rb'

class BaseSignupControllerTest < ActionController::TestCase
  include BaseSignupControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
