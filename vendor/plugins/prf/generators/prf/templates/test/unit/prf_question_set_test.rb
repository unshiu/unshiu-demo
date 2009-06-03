require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/unit/prf_question_set_test.rb'

class PrfQuestionSetTest < ActiveSupport::TestCase
  include PrfQuestionSetTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
    
end