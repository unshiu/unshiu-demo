require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_user_file_history_test.rb'

class BaseUserFileHistoryTest < ActiveSupport::TestCase
  include BaseUserFileHistoryTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
