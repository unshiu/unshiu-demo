require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/base/test/functional/manage/base_transit_controller_test.rb'

class Manage::BaseTransitControllerTest < ActionController::TestCase
  include Manage::BaseTransitControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
