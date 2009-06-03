require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/base/test/functional/manage/base_error_controller_test_module.rb'

class Manage::BaseErrorControllerTest < ActionController::TestCase
  include Manage::BaseErrorControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
