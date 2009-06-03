require "#{File.dirname(__FILE__)}/../test_helper"

module BaseInviteControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_ng_words
        fixtures :base_errors
      end
    end
  end

  define_method('test: 新規ユーザ招待を実行しようとするが、既に登録済みのメールアドレス。ただしセキュリティを考慮して完了画面は表示する') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_invite/create", :mail_address => 'mobilesns-dev@devml.drecom.co.jp', :invite_message => '招待するよ!!'
    assert_response :redirect
    assert_redirected_to :action => 'done'
  end
  
end