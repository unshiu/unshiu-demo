require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_guides_controller_mobile_test.rb'

class BaseGuidesControllerMobileTest < ActionController::TestCase
  include BaseGuidesControllerMobileTestModule
  
  def setup
    @controller = BaseGuidesController.new
    super
  end
  
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
