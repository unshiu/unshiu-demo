require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/unit/msg_message_test.rb'

class MsgMessageTest < ActiveSupport::TestCase
  include MsgMessageTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
