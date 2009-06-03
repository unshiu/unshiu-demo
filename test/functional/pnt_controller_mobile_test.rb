require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/functional/pnt_controller_mobile_test.rb'

class PntControllerMobileTest < ActionController::TestCase
  include PntControllerMobileTestModule
  
  def setup
    @controller = PntController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
