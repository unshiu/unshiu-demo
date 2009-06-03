require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/mlg/test/unit/lib/worker/mlg_add_target_users_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/mlg_add_target_users_worker"

class MlgAddTargetUsersWorkerTest < ActiveSupport::TestCase
  include MlgAddTargetUsersWorkerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
