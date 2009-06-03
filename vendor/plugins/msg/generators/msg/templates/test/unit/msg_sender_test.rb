require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/unit/msg_sender_test.rb'

class MsgSenderTest < ActiveSupport::TestCase
  include MsgSenderTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
