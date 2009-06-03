require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mlg/test/unit/mlg_delivery_test.rb'

class MlgDeliveryTest < ActiveSupport::TestCase
  include MlgDeliveryTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
