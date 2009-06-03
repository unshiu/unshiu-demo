require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/dia/test/functional/manage/dia_controller_test.rb'
require 'manage/dia_controller'

# Re-raise errors caught by the controller.
class Manage::DiaController; def rescue_action(e) raise e end; end

class Manage::DiaControllerTest < ActionController::TestCase
  include Manage::DiaControllerTestModule
  
  def setup
    @controller = Manage::DiaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
