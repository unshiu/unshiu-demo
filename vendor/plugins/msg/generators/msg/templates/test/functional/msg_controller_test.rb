require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/msg/test/functional/msg_controller_test.rb'
require 'msg_controller'

# Re-raise errors caught by the controller.
class MsgController; def rescue_action(e) raise e end; end

class MsgControllerTest < ActionController::TestCase
  include MsgControllerTestModule
  
  def setup
    @controller = MsgController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
