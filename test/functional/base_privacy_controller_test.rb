require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_privacy_controller_test_module.rb'
require 'base_privacy_controller'

# Re-raise errors caught by the controller.
class BasePrivacyController; def rescue_action(e) raise e end; end

class BasePrivacyControllerTest < ActionController::TestCase
  include BasePrivacyControllerTestModule
  
  def setup
    @controller = BasePrivacyController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
