require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/functional/pnt_controller_test.rb'

class PntControllerTest < ActionController::TestCase
  include PntControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
