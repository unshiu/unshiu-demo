require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/functional/pnt_point_system_test.rb'

class PntPointSystemTest < ActionController::TestCase
  include PntPointSystemTestModule
  
  def setup
    @controller = PointSystemTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
    
end