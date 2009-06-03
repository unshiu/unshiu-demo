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

class DiaEntriesAbmImage < ActiveRecord::Base
  include DiaEntriesAbmImageModule
end
