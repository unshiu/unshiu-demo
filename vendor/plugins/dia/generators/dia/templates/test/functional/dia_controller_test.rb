require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/dia/test/functional/dia_controller_test.rb'
require 'dia_controller'

# Re-raise errors caught by the controller.
class DiaController; def rescue_action(e) raise e end; end

class DiaControllerTest < ActionController::TestCase
  include DiaControllerTestModule
  
  def setup
    @controller = DiaController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
