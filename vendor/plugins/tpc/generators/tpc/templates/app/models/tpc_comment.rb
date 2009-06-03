# == Schema Information
#
# Table name: tpc_comments
#
#  id            :integer(4)      not null, primary key
#  title         :string(255)
#  body          :text
#  tpc_topic_id  :integer(4)      not null
#  base_user_id  :integer(4)      not null
#  created_at    :datetime
#  updated_at    :datetime
#  invisibled_by :integer(4)
#

class TpcComment < ActiveRecord::Base
  include TpcCommentModule
end
