require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_mail_dispatch_info_test_module.rb'

class BaseMailDispatchInfoTest < ActiveSupport::TestCase
  include BaseMailDispatchInfoTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
