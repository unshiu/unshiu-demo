require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/functional/cmm_user_controller_mobile_test.rb'

class CmmUserControllerMobileTest < ActionController::TestCase
  include CmmUserControllerMobileTestModule
  
  def setup
    @controller = CmmUserController.new
    super
    
    setup_fixture_files
    
    @user1  = base_users(:quentin)
    @user2  = base_users(:aaron)
    @community1 = cmm_communities(:one)
    @community2 = cmm_communities(:two)
    @community3 = cmm_communities(:three)
    @community4 = cmm_communities(:four)
    @community_base_user1 = cmm_communities_base_users(:one_ADMIN)
  end
  
  def teardown
    teardown_fixture_files
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
