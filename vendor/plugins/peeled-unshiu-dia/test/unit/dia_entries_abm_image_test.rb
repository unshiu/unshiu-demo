require File.dirname(__FILE__) + '/../test_helper'

module DiaEntriesAbmImageTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :dia_entries
        fixtures :dia_entries_abm_images
        fixtures :abm_images
      end
    end
  end
  
  def test_relation
    deai = DiaEntriesAbmImage.find(1)
    assert_not_nil deai.dia_entry
    assert_not_nil deai.abm_image
  end
end
