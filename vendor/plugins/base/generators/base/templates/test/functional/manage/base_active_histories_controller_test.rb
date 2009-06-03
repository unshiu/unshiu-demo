require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/base/test/functional/manage/base_active_histories_controller_test.rb'

class Manage::BaseActiveHistoriesControllerTest < ActionController::TestCase
  include Manage::BaseActiveHistoriesControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
end