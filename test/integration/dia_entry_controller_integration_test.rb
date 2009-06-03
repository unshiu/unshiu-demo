require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../vendor/plugins/dia/test/integration/dia_entry_controller_integration_test.rb'

class DiaEntryControllerIntegrationTest < ActionController::IntegrationTest
  include DiaEntryControllerIntegrationTestModule
  
  # You must write Integration Test!!
  def test_default
    assert true
  end
  
end