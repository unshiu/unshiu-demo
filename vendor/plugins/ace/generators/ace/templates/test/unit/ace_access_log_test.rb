require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/ace/test/unit/ace_access_log_test.rb'

class AceAccessLogTest < ActiveSupport::TestCase
  include AceAccessLogTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
