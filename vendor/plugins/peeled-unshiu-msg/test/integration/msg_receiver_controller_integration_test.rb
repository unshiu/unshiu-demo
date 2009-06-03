require "#{File.dirname(__FILE__)}/../test_helper"

module MsgReceiverControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 複数の受信メッセージ削除の確認画面を表示しようとするが、自分の受信メッセージじゃないものが含まれているのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "msg_receiver/delete_messages_confirm", :del => { 1 => true, 5 => true } # 5 は quentinの受信メッセージ
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-06007"
  end
  
end