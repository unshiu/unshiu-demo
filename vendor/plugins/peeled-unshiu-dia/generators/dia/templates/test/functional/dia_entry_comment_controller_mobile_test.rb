require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/dia/test/functional/dia_entry_comment_controller_mobile_test.rb'

class DiaEntryCommentControllerMobileTest < ActionController::TestCase
  include DiaEntryCommentControllerMobileTestModule
  
  def setup
    @controller = DiaEntryCommentController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
