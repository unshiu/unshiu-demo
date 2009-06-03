module Forms
  module BaseInviteFormModule
  
    class << self
      def included(base)
        base.class_eval do
          include BaseMailAddressFormModule
        
          attr_accessor :invite_message

          validates_presence_of :invite_message
          validates_good_word_of :invite_message
        end
      end    
    end
    
  end
end
