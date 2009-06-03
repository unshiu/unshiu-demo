require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/unit/pnt_filter_test.rb'

class PntFilterTest < ActiveSupport::TestCase
  include PntFilterTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
