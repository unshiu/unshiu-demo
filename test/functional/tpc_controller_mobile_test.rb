require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/tpc/test/functional/tpc_controller_mobile_test.rb'

class TpcControllerMobileTest < ActionController::TestCase
  include TpcControllerMobileTestModule
  
  def setup
    @controller = TpcController.new
    super
    
    @user1  = base_users(:quentin)
    @user2  = base_users(:aaron)
    @topic1 = tpc_topics(:one)
    @topic2 = tpc_topics(:two)
    @tpc_community1 = tpc_topic_cmm_communities(:one)
    @tpc_community2 = tpc_topic_cmm_communities(:two)
    @tpc_community3 = tpc_topic_cmm_communities(:three)
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
