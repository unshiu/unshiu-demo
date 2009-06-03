require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/dia/test/functional/dia_diary_controller_test.rb'
require 'dia_diary_controller'

# Re-raise errors caught by the controller.
class DiaDiaryController; def rescue_action(e) raise e end; end

class DiaDiaryControllerTest < ActionController::TestCase
  include DiaDiaryControllerTestModule
  
  def setup
    @controller = DiaDiaryController.new
    super
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
