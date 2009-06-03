require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_friend_controller_test.rb'

class BaseFriendControllerTest < ActionController::TestCase
  include BaseFriendControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
