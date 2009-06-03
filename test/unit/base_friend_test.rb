require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_friend_test_module.rb'

class BaseFriendTest < ActiveSupport::TestCase
  include BaseFriendTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
