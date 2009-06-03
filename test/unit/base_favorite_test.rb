require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/unit/base_favorite_test_module.rb'

class BaseFavoriteTest < ActiveSupport::TestCase
  include BaseFavoriteTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
