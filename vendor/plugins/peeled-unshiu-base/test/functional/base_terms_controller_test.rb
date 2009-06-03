
module BaseTermsControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
      end
    end
  end
  
  # ロジックを使っていないのでテストする内容はいまのところなし
  
end