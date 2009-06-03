require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/functional/prf_controller_mobile_test.rb'

class PrfControllerMobileTest < ActionController::TestCase
  include PrfControllerMobileTestModule
  
  def setup
    @controller = PrfController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
