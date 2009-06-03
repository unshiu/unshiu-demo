require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_friend_apply_controller_mobile_test.rb'

class BaseFriendApplyControllerMobileTest < ActionController::TestCase
  include BaseFriendApplyControllerMobileTestModule
  
  def setup
    @controller = BaseFriendApplyController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end

end
