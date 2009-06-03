require File.dirname(__FILE__) + '/../test_helper'

module PntUpdateErrorRecordTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :pnt_update_error_records
      end
    end
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
