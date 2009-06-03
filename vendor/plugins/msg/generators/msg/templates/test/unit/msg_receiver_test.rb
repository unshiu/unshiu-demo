require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/unit/msg_receiver_test.rb'

class MsgReceiverTest < ActiveSupport::TestCase
  include MsgReceiverTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
