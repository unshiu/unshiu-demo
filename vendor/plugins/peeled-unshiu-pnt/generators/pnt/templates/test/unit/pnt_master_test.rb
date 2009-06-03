require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/pnt/test/unit/pnt_master_test.rb'

class PntMasterTest < ActiveSupport::TestCase
  include PntMasterTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
