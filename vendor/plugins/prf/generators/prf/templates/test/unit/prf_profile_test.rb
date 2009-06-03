require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/unit/prf_profile_test.rb'

class PrfProfileTest < ActiveSupport::TestCase
  include PrfProfileTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
