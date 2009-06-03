require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_plugin_test.rb'

class BasePluginTest < ActiveSupport::TestCase
  include BasePluginTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
end
