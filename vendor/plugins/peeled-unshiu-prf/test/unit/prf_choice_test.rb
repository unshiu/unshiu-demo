require File.dirname(__FILE__) + '/../test_helper'

module PrfChoiceTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :prf_choices
      end
    end
  end
  
  def test_has_free_area?
    assert !PrfChoice.find(12).has_free_area?
    assert PrfChoice.find(13).has_free_area?
    assert PrfChoice.find(14).has_free_area?
  end
  
  def test_has_free_area_text?
    assert !PrfChoice.find(12).free_area_type_text?
    assert PrfChoice.find(13).free_area_type_text?
    assert !PrfChoice.find(14).free_area_type_text?
  end

  def test_has_free_area_textarea?
    assert !PrfChoice.find(12).free_area_type_textarea?
    assert !PrfChoice.find(13).free_area_type_textarea?
    assert PrfChoice.find(14).free_area_type_textarea?
  end
end
