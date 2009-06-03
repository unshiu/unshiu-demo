module Forms
  module BaseMailTemplateSendTestFormModule
  
    class << self
      def included(base)
        base.class_eval do
          include BaseMailAddressFormModule
        end
      end
    end
    
  end
end
