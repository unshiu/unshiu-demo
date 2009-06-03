require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/dia/test/functional/manage/dia_entry_comment_controller_test.rb'
require 'manage/dia_entry_comment_controller'

# Re-raise errors caught by the controller.
class Manage::DiaEntryCommentController; def rescue_action(e) raise e end; end

class Manage::DiaEntryCommentControllerTest < ActionController::TestCase
  include Manage::DiaEntryCommentControllerTestModule
  
  def setup
    @controller = Manage::DiaEntryCommentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
