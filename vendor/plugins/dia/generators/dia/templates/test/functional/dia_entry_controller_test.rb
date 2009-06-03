require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/dia/test/functional/dia_entry_controller_test.rb'

class DiaEntryControllerTest < ActionController::TestCase
  include DiaEntryControllerTestModule
  
  def setup
    setup_fixture_files
    super
  end

  def teardown
    teardown_fixture_files
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
