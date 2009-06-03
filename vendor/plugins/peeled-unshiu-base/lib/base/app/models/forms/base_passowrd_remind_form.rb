module Forms
  module BasePasswordRemindFormModule
  
    class << self
      def included(base)
        base.class_eval do
          include BaseMailAddressFormModule
        end
      end
    end
  
    def validate
      user = BaseUser.find_by_email(self.mail_address)
      if user.nil? || !user.active?
        self.errors.add('mail_address', 'に該当するユーザーが見つかりませんでした。')
      end
    end
  end
end