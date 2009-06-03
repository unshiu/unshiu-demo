# == Schema Information
#
# Table name: dia_entries_abm_images
#
#  id           :integer(4)      not null, primary key
#  dia_entry_id :integer(4)      not null
#  abm_image_id :integer(4)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

module DiaEntriesAbmImageModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid

        belongs_to :dia_entry
        belongs_to :abm_image
        
        validates_numericality_of :dia_entry_id, :abm_image_id
      end
    end
  end
  
end
