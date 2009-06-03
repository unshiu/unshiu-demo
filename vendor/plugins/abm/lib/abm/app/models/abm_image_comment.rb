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

module AbmImageCommentModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_invisible :abm_image => :abm_album
        
        belongs_to :abm_image
        belongs_to :base_user
        
        validates_length_of :body, :maximum => AppResources['base']['comment_max_length']
        validates_presence_of :body
        validates_good_word_of :body
        
        named_scope :recent, lambda { |limit| 
          {:limit => limit, :order => ['created_at desc'] } 
        }
      end
    end
  end
  
  def mine?(base_user)
    return false unless base_user
    
    self.base_user_id == base_user.id
  end

  # 削除権限がある base_user なら true
  def deletable?(base_user)
    if self.mine?(base_user)
      return true
    elsif self.abm_image.mine?(base_user.id)
      return true
    else
      return false
    end
  end
end
