require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_mail_template_test.rb'

class BaseMailTemplateTest < ActiveSupport::TestCase
  include BaseMailTemplateTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
end
