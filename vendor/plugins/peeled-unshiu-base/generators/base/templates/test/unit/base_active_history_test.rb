require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_active_history_test.rb'

class BaseActiveHistoryTest < ActiveSupport::TestCase
  include BaseActiveHistoryTestModule
  
  # You must write UnitTest!!
  test "the truth" do
    assert true
  end
  
end
