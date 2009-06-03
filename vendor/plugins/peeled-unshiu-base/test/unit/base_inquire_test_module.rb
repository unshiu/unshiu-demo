require File.dirname(__FILE__) + '/../test_helper'

module BaseInquireTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_inquires
      end
    end
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end

end