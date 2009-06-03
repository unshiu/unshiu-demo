require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_notice_controller_mobile_test.rb'

class BaseNoticeControllerMobileTest < ActionController::TestCase
  include BaseNoticeControllerMobileTestModule
  
  def setup
    @controller = BaseNoticeController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
