require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/base/test/functional/manage/base_user_controller_test_module.rb'

class Manage::BaseUserControllerTest < ActionController::TestCase
  include Manage::BaseUserControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
