require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_user_config_controller_mobile_test.rb'

class BaseUserConfigControllerMobileTest < ActionController::TestCase
  include BaseUserConfigControllerMobileTestModule
  
  def setup
    @controller = BaseUserConfigController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
