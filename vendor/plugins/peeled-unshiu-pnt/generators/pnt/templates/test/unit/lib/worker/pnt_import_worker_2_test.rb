require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/pnt/test/unit/lib/worker/pnt_import_worker_2_test.rb'
require "#{RAILS_ROOT}/lib/workers/pnt_import_worker"

class PntImportWorker2Test < ActiveSupport::TestCase
  include PntImportWorkerTest2Module

  # You must write UnitTest!!
  def test_default
    assert true
  end

end