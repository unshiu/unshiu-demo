
module MsgManagerSendWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :msg_manager_send_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  # アクティブなユーザ全員に指定メッセージを送る
  # FIXME ユーザが増えたら破綻する
  def all_user_send_message(arg = {})
    message = MsgMessage.find(arg[:message_id])
    users = BaseUser.active_users
    for user in users
      msg_receiver = MsgReceiver.new
      msg_receiver.base_user_id = user.id
      msg_receiver.msg_message_id = message.id
      msg_receiver.save
    end
  end
  
end
