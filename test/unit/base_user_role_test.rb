require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_user_role_test_module.rb'

class BaseUserRoleTest < ActiveSupport::TestCase
  include BaseUserRoleTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
