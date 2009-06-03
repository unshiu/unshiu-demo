require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_invite_controller_test_module.rb'
require 'base_invite_controller'

# Re-raise errors caught by the controller.
class BaseInviteController; def rescue_action(e) raise e end; end

class BaseInviteControllerTest < ActionController::TestCase
  include BaseInviteControllerTestModule
  
  def setup
    @controller = BaseInviteController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
