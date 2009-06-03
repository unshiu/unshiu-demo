require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/unit/pnt_history_test.rb'

class PntHistoryTest < ActiveSupport::TestCase
  include PntHistoryTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
