# == Schema Information
#
# Table name: tpc_topic_abm_images
#
#  id           :integer(4)      not null, primary key
#  tpc_topic_id :integer(4)      not null
#  abm_image_id :integer(4)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

class TpcTopicAbmImage < ActiveRecord::Base
  include TpcTopicAbmImageModule
end
