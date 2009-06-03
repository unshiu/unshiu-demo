require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_ng_word_test_module.rb'

class BaseNgWordTest < ActiveSupport::TestCase
  include BaseNgWordTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
