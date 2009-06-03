require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mng/test/unit/mng_apache_log_test.rb'

class MngApacheLogTest < ActiveSupport::TestCase
  include MngApacheLogTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end

end
