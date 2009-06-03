require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/prf/test/functional/manage/prf_controller_test.rb'
require 'manage/prf_controller'

# Re-raise errors caught by the controller.
class Manage::PrfController; def rescue_action(e) raise e end; end

class Manage::PrfControllerTest < ActionController::TestCase
  include Manage::PrfControllerTestModule
  
  def setup
    @controller = Manage::PrfController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end