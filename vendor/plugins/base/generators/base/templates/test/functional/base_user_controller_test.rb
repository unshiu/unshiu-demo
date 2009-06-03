require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_user_controller_test_module.rb'
require 'base_user_controller'

# Re-raise errors caught by the controller.
class BaseUserController; def rescue_action(e) raise e end; end

class BaseUserControllerTest < ActionController::TestCase
  include BaseUserControllerTestModule

  def setup
    @controller = BaseUserController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
