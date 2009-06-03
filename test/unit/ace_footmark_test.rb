require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/ace/test/unit/ace_footmark_test.rb'

class AceFootmarkTest < ActiveSupport::TestCase
  include AceFootmarkTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
