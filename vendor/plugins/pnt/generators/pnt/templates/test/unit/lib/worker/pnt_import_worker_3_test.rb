require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/pnt/test/unit/lib/worker/pnt_import_worker_3_test.rb'
require "#{RAILS_ROOT}/lib/workers/pnt_import_worker"

class PntImportWorker3Test < ActiveSupport::TestCase
  include PntImportWorkerTest3Module

  # You must write UnitTest!!
  def test_default
    assert true
  end

end