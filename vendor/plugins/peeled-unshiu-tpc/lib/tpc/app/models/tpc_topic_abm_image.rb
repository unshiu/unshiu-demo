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

module TpcTopicAbmImageModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :tpc_topic
        belongs_to :abm_image
      end
    end
  end
  
end
