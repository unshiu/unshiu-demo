#
# 管理画面でのユーザ検索用form
#
module Forms
  module BaseUserSearchFormModule
  
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :start_point, :end_point
          attr_accessor :start_age, :end_age
          attr_accessor :joined_start_at, :joined_end_at

          validates_numericality_of :start_point, :end_point, :allow_blank => true
          validates_numericality_of :start_age, :end_age, :allow_blank => true
          validates_date :joined_start_at 
          validates_date :joined_end_at
        end
      end
    end
    
  end
end