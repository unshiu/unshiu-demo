# == Schema Information
#
# Table name: mng_user_action_history_archives
#
#  id             :integer(4)      not null, primary key
#  filename       :string(255)     not null
#  filesize       :integer(4)      not null
#  start_datetime :datetime        not null
#  end_datetime   :datetime        not null
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class MngUserActionHistoryArchive < ActiveRecord::Base
end
