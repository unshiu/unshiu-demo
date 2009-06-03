# == Schema Information
#
# Table name: dia_entries
#
#  id                :integer(4)      not null, primary key
#  dia_diary_id      :integer(4)      not null
#  title             :string(255)     default(""), not null
#  body              :text
#  public_level      :integer(4)
#  draft_flag        :boolean(1)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  last_commented_at :datetime
#  contributed_at    :datetime
#

class DiaEntry < ActiveRecord::Base
  include DiaEntryModule
end
