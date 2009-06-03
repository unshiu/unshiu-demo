require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/unit/prf_answer_test.rb'

class PrfAnswerTest < ActiveSupport::TestCase
  include PrfAnswerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
