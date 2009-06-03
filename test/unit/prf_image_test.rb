require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/unit/prf_image_test.rb'

class PrfImageTest < ActiveSupport::TestCase
  include PrfImageTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
