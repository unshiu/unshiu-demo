require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_user_test.rb'

class BaseUserTest < ActiveSupport::TestCase
  include BaseUserTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
