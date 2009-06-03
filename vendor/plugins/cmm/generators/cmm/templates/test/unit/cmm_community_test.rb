require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/unit/cmm_community_test.rb'

class CmmCommunityTest < ActiveSupport::TestCase
  include CmmCommunityTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
