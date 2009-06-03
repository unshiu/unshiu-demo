# == Schema Information
#
# Table name: abm_image_comments
#
#  id            :integer(4)      not null, primary key
#  base_user_id  :integer(4)      not null
#  abm_image_id  :integer(4)      not null
#  body          :text
#  created_at    :datetime
#  updated_at    :datetime
#  invisibled_by :integer(4)
#

class AbmImageComment < ActiveRecord::Base
  include AbmImageCommentModule
end
