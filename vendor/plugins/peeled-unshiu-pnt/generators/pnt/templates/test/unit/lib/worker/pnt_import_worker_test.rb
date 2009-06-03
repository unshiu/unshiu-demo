require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/pnt/test/unit/lib/worker/pnt_import_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/pnt_import_worker"
 
class PntImportWorkerTest < ActiveSupport::TestCase
  include PntImportWorkerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
