require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/unit/prf_question_test.rb'

class PrfQuestionTest < ActiveSupport::TestCase
  include PrfQuestionTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end