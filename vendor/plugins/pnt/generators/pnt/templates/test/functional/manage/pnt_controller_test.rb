require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/pnt/test/functional/manage/pnt_controller_test.rb'
require 'manage/pnt_controller'

# Re-raise errors caught by the controller.
class Manage::PntController; def rescue_action(e) raise e end; end

class Manage::PntControllerTest < ActionController::TestCase
  include ManagePntControllerTestModule
  
  def setup
    @controller = Manage::PntController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
