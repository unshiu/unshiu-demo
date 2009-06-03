# == Schema Information
#
# Table name: base_active_histories
#
#  id          :integer(4)      not null, primary key
#  history_day :date
#  before_days :integer(4)
#  user_count  :integer(4)
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

module BaseActiveHistoryModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        
        const_set('BEFORE_DAYS_LIST', [3, 7, 14, 30])
        
        named_scope :before, lambda { |day| 
          {:conditions => ['before_days = ? ', day], :order => ['history_day desc'] } 
        }
      end
    end
  end
  
end
