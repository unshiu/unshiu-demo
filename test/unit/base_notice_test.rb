require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_notice_test_module.rb'

class BaseNoticeTest < ActiveSupport::TestCase
  include BaseNoticeTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
