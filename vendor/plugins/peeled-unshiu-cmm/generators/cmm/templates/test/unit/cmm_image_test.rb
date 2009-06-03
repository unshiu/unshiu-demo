require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/cmm/test/unit/cmm_image_test.rb'

class CmmImageTest < ActiveSupport::TestCase
  include CmmImageTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
