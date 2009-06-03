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

module MsgNotifyModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid

        validates_presence_of :comment
        validates_length_of :comment, :maximum => AppResources[:base][:body_max_length]
        validates_good_word_of :comment
      end
    end
  end
  
end
