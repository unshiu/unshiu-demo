require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mng/test/unit/mng_system_test.rb'

class MngSystemTest < ActiveSupport::TestCase
  include MngSystemTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end

end
