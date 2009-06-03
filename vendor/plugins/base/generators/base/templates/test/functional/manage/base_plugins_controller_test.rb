require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/base/test/functional/manage/base_plugins_controller_test.rb'

class Manage::BasePluginsControllerTest < ActionController::TestCase
  include Manage::BasePluginsControllerTestModule

  # You must write UnitTest!!
  def test_default
   assert true
  end
end