require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/msg/test/unit/lib/worker/msg_manager_send_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/msg_manager_send_worker"

class MsgManagerSendWorkerTest < ActiveSupport::TestCase
  include MsgManagerSendWorkerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
