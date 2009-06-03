# == Schema Information
#
# Table name: msg_notifies
#
#  id             :integer(4)      not null, primary key
#  msg_message_id :integer(4)
#  comment        :text
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

class MsgNotify < ActiveRecord::Base
  include MsgNotifyModule
end
