# == Schema Information
#
# Table name: base_friends
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  friend_id    :integer(4)      not null
#  status       :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

class BaseFriend < ActiveRecord::Base
  include BaseFriendModule
end
