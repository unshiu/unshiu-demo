require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/mng/test/functional/manage/mng_user_controller_test.rb'
require 'manage/mng_user_controller'

# Re-raise errors caught by the controller.
class Manage::MngUserController; def rescue_action(e) raise e end; end

class Manage::MngUserControllerTest < ActionController::TestCase
  include ManageMngUserControllerTestModule
  
  def setup
    @controller = Manage::MngUserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
