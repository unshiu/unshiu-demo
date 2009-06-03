require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/unit/abm_image_test.rb'

class AbmImageTest < ActiveSupport::TestCase
  include AbmImageTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
