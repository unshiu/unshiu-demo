require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/unit/msg_notify_test.rb'

class MsgNotifyTest < ActiveSupport::TestCase
  include MsgNotifyTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
