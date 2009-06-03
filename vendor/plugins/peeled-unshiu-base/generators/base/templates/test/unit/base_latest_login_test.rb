require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_latest_login_test.rb'

class BaseLatestLoginTest < ActiveSupport::TestCase
  include BaseLatestLoginTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end

end