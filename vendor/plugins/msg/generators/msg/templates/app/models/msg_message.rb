# == Schema Information
#
# Table name: msg_messages
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)     default(""), not null
#  body              :text
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  parent_message_id :integer(4)
#

class MsgMessage < ActiveRecord::Base
  include MsgMessageModule
end
