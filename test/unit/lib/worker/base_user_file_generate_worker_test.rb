require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/base/test/unit/lib/worker/base_user_file_generate_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/base_user_file_generate_worker"

class BaseUserFileGenerateWorkerTest < ActiveSupport::TestCase
  include BaseUserFileGenerateWorkerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
