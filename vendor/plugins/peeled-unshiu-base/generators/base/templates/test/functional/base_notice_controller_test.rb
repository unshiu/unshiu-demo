require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_notice_controller_test.rb'

class BaseNoticeControllerTest < ActionController::TestCase
  include BaseNoticeControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
