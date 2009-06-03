require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/dia/test/unit/dia_diary_test.rb'

class DiaDiaryTest < ActiveSupport::TestCase
  include DiaDiaryTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
