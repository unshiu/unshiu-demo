require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/base/test/unit/lib/worker/base_active_history_create_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/base_active_history_create_worker"

class BaseActiveHistoryCreateWorkerTest < ActiveSupport::TestCase
  include BaseActiveHistoryCreateWorkerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
