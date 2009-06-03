# == Schema Information
#
# Table name: dia_entry_comments
#
#  id            :integer(4)      not null, primary key
#  base_user_id  :integer(4)      not null
#  dia_entry_id  :integer(4)      not null
#  body          :text
#  created_at    :datetime
#  updated_at    :datetime
#  read_flag     :boolean(1)      not null
#  invisibled_by :integer(4)
#

class DiaEntryComment < ActiveRecord::Base
  include DiaEntryCommentModule
end
