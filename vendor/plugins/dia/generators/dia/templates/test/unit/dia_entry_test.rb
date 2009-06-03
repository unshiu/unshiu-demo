require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/dia/test/unit/dia_entry_test.rb'

class DiaEntryTest < ActiveSupport::TestCase
  include DiaEntryTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end