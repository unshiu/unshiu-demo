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
#  comment_count     :integer(4)      default(0)
#

module TpcTopicModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :base_user
        has_many :tpc_comments, :dependent => :destroy
        has_many :tpc_topic_abm_images, :dependent => :destroy
        has_many :abm_images, :through => :tpc_topic_abm_images

        validates_length_of :title, :maximum => AppResources['base']['title_max_length']
        validates_length_of :body, :maximum => AppResources['base']['body_max_length']
        validates_presence_of :title, :body
        validates_good_word_of  :title, :body
        
        after_create :create_last_commented_at
      end
    end
  end
  
  def latest_at
    return last_commented_at || created_at
  end
  
private

  def create_last_commented_at
    self.last_commented_at = self.created_at
    self.save
  end
end
