require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_friend_controller_mobile_test.rb'

class BaseFriendControllerMobileTest < ActionController::TestCase
  include BaseFriendControllerMobileTestModule
  
  def setup
    @controller = BaseFriendController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
