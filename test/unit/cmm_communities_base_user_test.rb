require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/unit/cmm_communities_base_user_test.rb'

class CmmCommunitiesBaseUserTest < ActiveSupport::TestCase
  include CmmCommunitiesBaseUserTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
