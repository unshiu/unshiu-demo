require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_controller_mobile_test.rb'

class BaseControllerMobileTest < ActionController::TestCase
  include BaseControllerMobileTestModule
  
  def setup
    @controller = BaseController.new
    super
  end
   
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
