require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_profile_test_module.rb'

class BaseProfileTest < ActiveSupport::TestCase
  include BaseProfileTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
