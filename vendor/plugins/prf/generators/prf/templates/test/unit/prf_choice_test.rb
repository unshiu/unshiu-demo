require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/unit/prf_choice_test.rb'

class PrfChoiceTest < ActiveSupport::TestCase
  include PrfChoiceTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
