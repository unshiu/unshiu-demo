require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/mng/test/unit/lib/worker/mng_user_action_history_archive_create_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/mng_user_action_history_archive_create_worker"


class MngUserActionHistoryArchiveCreateWorkerTest < ActiveSupport::TestCase
  include MngUserActionHistoryArchiveCreateWorkerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end