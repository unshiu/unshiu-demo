require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/dia/test/functional/manage/dia_entry_controller_test.rb'
require 'manage/dia_entry_controller'

# Re-raise errors caught by the controller.
class Manage::DiaEntryController; def rescue_action(e) raise e end; end

class Manage::DiaEntryControllerTest < ActionController::TestCase
  include Manage::DiaEntryControllerTestModule
  
  def setup
    @controller = Manage::DiaEntryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    DiaEntry.clear_index!
    DiaEntry.reindex!
    
    setup_fixture_files
  end

  def teardown
    teardown_fixture_files
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
