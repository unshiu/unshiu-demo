# == Schema Information
#
# Table name: msg_receivers
#
#  id             :integer(4)      not null, primary key
#  msg_message_id :integer(4)      not null
#  base_user_id   :integer(4)      not null
#  trash_status   :integer(2)
#  replied_flag   :boolean(1)      not null
#  read_flag      :boolean(1)      not null
#  draft_flag     :boolean(1)
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

class MsgReceiver < ActiveRecord::Base
  include MsgReceiverModule
end
