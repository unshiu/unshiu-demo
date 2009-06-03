# == Schema Information
#
# Table name: tpc_topics
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)
#  body              :text
#  base_user_id      :integer(4)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  last_commented_at :datetime
#

class TpcTopic < ActiveRecord::Base
  include TpcTopicModule
end
