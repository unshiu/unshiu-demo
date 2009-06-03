
module BaseTermsControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
      end
    end
  end
  
  # ロジックを使っていないのでテストする内容はいまのところなし
  
end