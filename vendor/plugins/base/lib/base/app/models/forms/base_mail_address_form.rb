
module Forms
  module BaseMailAddressFormModule
  
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :mail_address
        
          validates_presence_of :mail_address
          validates_length_of   :mail_address,  :within => 3..AppResources[:base][:email_max_length]
          validates_legal_mail_address_of :mail_address, :if => Proc.new{|form| !form.mail_address.blank?}
        
        end
      end
    
    end
  end
end