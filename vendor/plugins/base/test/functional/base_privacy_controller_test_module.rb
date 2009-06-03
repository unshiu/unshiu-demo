
module BasePrivacyControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
      end
    end
  end

  # 会社のプライバシー規約等を表示するだけのcontrollerなので特にテストは含まれていない
end