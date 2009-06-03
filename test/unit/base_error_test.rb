require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_error_test.rb'

class BaseErrorTest < ActiveSupport::TestCase
  include BaseErrorTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
