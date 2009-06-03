require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/msg_manager_send_worker"

module MsgManagerSendWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        self.use_transactional_fixtures = false
        
        fixtures :base_users
        fixtures :base_friends
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
      end
    end
  end
  
  define_method('test: ユーザ全員へメッセージを送信するテスト') do 
    request_params = Hash.new
    request_params[:message_id] = MsgMessage.find(1)
    
    receiver_count = MsgReceiver.count
    assert_equal receiver_count, 13 # FIXME 13 というテスト結果であることを確認したい訳ではないので要修正
    
    worker = MsgManagerSendWorker.new
    worker.all_user_send_message(request_params)
    
    after_receiver_count = MsgReceiver.count
    assert_equal after_receiver_count, receiver_count + 6  # アクティブなユーザは6名なので
    
  end
  
end
