require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/unit/pnt_point_test.rb'

class PntPointTest < ActiveSupport::TestCase
  include PntPointTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
