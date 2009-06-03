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

module TpcCommentModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_invisible :tpc_topic

        belongs_to :base_user
        belongs_to :tpc_topic

        validates_presence_of :body
        validates_good_word_of :body
        validates_length_of :body, :maximum => AppResources['base']['comment_max_length']
        
        named_scope :recent, lambda { |limit| 
          {:limit => limit, :order => ['created_at desc'] } 
        }
        
        after_save :update_tpc_topic_last_commented_at
        after_create :update_tpc_topic_comment_count
      end
    end
  end
  
private

  def update_tpc_topic_last_commented_at
    self.tpc_topic.last_commented_at = Time.now
    self.tpc_topic.save
  end
  
  def update_tpc_topic_comment_count
    self.tpc_topic.comment_count = self.tpc_topic.tpc_comments.count
    self.tpc_topic.save
  end
end
