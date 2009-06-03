require File.dirname(__FILE__) + '/../test_helper'

module PrfImageTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :prf_images
      end
    end
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
