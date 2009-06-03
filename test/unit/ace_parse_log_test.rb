require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/ace/test/unit/ace_parse_log_test.rb'

class AceParseLogTest < ActiveSupport::TestCase
  include AceParseLogTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
