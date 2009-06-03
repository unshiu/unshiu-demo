require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/base/test/functional/manage/base_ng_word_controller_test_module.rb'

class Manage::BaseNgWordControllerTest < ActionController::TestCase
  include Manage::BaseNgWordControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
