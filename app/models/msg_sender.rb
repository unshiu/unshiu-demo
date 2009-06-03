# == Schema Information
#
# Table name: msg_senders
#
#  id             :integer(4)      not null, primary key
#  msg_message_id :integer(4)      not null
#  base_user_id   :integer(4)      not null
#  trash_status   :integer(2)
#  draft_flag     :boolean(1)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

class MsgSender < ActiveRecord::Base
  include MsgSenderModule
end
