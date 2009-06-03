require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/cmm/test/functional/manage/cmm_controller_test.rb'

class Manage::CmmControllerTest < ActionController::TestCase
  include Manage::CmmControllerTestModule
    
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
