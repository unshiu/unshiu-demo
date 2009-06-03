require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_mailer_notifier_test_module.rb'

class BaseMailerNotifierTest < ActiveSupport::TestCase
  include BaseMailerNotifierTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
