require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/pnt/test/functional/manage/pnt_master_controller_test.rb'
require 'manage/pnt_master_controller'

# Re-raise errors caught by the controller.
class Manage::PntMasterController; def rescue_action(e) raise e end; end

class Manage::PntMasterControllerTest < ActionController::TestCase
  include ManagePntMasterControllerTestModule
  
  def setup
    @controller = Manage::PntMasterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
