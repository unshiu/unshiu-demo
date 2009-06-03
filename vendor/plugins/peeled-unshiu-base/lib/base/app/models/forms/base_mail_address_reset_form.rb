module Forms
  module BaseMailAddressResetFormModule 
  
    class << self
      def included(base)
        base.class_eval do
          include BaseMailAddressFormModule
        end
      end
    end
  
    def validate
      user = BaseUser.find_by_email(self.mail_address)
      if user && (user.active? || user.forbidden?)
        self.errors.add('mail_address', I18n.t('activerecord.errors.messages.base_user_exclusion'))
      end
    end
  end
end