require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/tpc/test/functional/tpc_cmm_controller_mobile_test.rb'

class TpcCmmControllerMobileTest < ActionController::TestCase
  include TpcCmmControllerMobileTestModule
    
  def setup
    @controller = TpcCmmController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
