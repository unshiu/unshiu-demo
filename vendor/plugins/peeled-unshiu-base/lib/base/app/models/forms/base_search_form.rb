#
# PCでの全体検索用form
#
module Forms
  module BaseSearchFormModule
  
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :keyword, :scope

          validates_presence_of :scope
        end
      end
    end
    
  end
end