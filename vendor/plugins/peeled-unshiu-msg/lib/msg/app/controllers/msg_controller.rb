
module MsgControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
      end
    end
  end
  
protected

  def receiver_check
    return unless params[:receivers]
    params[:receivers].each do |receiver|
      unless MsgMessage.acceptable?(current_base_user, receiver)
        redirect_to_error('U-06001')
        return false
      end
    end
  end
  
  # params[:id] の id を持つ MsgMessage の送信者でも受信者でもなければエラー
  # params[:id] が nil であるか、params[:id] で指定されるメッセージが存在しなかったらエラー
  def owner_only
    return false unless nil_check
  
    message = MsgMessage.find(params[:id])
    unless message.sender?(current_base_user) || message.receiver?(current_base_user)
      redirect_to_error("U-06002")
      return false
    end
  end
  
  # params[:id] の id を持つ MsgMessage の受信者でなければエラー
  # params[:id] が nil であるか、params[:id] で指定されるメッセージが存在しなかったらエラー
  def receiver_only
    return false unless nil_check
    
    message = MsgMessage.find(params[:id])
    unless message.receiver?(current_base_user)
      redirect_to_error("U-06005")
      return false
    end
    return true
  end
  
  # params[:id] の id を持つ MsgMessage の受信者でなければエラー
  # params[:id] が nil であるか、params[:id] で指定されるメッセージが存在しなかったらエラー
  # 現時点で送信者の BaseUser が存在しなかったらエラー
  def receiver_only_and_exists_sender
    return false unless receiver_only
    
    message = MsgMessage.find(params[:id])
    if message.msg_sender.base_user == nil
      redirect_to_error("送信#{I18n.t('view.noun.base_user')}が存在しません。")
      return false
    end
  end
  
  # params[:id] の id を持つ MsgMessage の送信者でなければエラー
  # params[:id] が nil であるか、params[:id] で指定されるメッセージが存在しなかったらエラー
  def sender_only
    return false unless nil_check
    
    message = MsgMessage.find(params[:id])
    unless message.sender?(current_base_user)
      redirect_to_error("U-06003")
      return false
    end
    return true
  end
  
  # params[:id] の id を持つ MsgMessage の送信者でなければエラー
  # params[:id] が nil であるか、params[:id] で指定されるメッセージが存在しなかったらエラー
  # 現時点で受信者の BaseUser が存在しなかったらエラー
  def sender_only_and_exists_receiver
    return false unless sender_only
    
    message = MsgMessage.find(params[:id])
    unless message.msg_receivers.all? { |receiver| receiver.base_user != nil }
      redirect_to_error("受信#{I18n.t('view.noun.base_user')}が存在しません。")
      return false
    end
  end
  
  # params[:id] が nil であるか、params[:id] で指定されるメッセージが存在しなかったらエラー
  def nil_check
    if params[:id] == nil
      redirect_to_error('U-06004')
      return false
    end
    
    if MsgMessage.find_by_id(params[:id]) == nil
      redirect_to_error('U-06004')
      return false
    end
    return true
  end
  
  # 削除対象に指定されたメッセージの送信者でなければエラー
  # 不正 post 対策
  def send_messages_only
    unless params[:del].nil?
      count = MsgMessage.count(:include => "msg_sender",
                               :conditions => ["msg_messages.id in (?) and msg_senders.base_user_id = ?", params[:del].keys, current_base_user.id])
      unless params[:del].keys.length == count
        redirect_to_error('U-06006')
        return false
      end
    end
  end

  # 削除対象に指定されたメッセージの受信者でなければエラー
  # 不正 post 対策
  def receive_messages_owner_required_for_mobile
    return true unless params[:del] # :delがない場合の処理は各actionで
    count = MsgMessage.count(:include => "msg_receivers",
      :conditions => ["msg_messages.id in (?) and msg_receivers.base_user_id = ?", params[:del].keys, current_base_user.id])
    unless params[:del].keys.length == count
      redirect_to_error('U-06007')
      return false
    end
  end
  
  # 削除対象に指定されたメッセージの受信者でなければエラー
  # 不正 post 対策
  def receive_messages_owner_required
    return true unless params[:message_ids] 
    # FIXME modelにあるべき
    count = MsgMessage.count(:include => "msg_receivers",
      :conditions => ["msg_messages.id in (?) and msg_receivers.base_user_id = ?", params[:message_ids], current_base_user.id])
    unless params[:message_ids].length == count
      redirect_to_error('U-06007')
      return false
    end
  end
  
  # 自分自身の各種メッセージボックス内のメッセージ数を取得する
  def setup_current_user_box_count
    @received_count = current_base_user.msg_receive_messages.count.to_s
    @sent_count = current_base_user.msg_send_messages.count.to_s
    @draft_count = current_base_user.msg_draft_messages.count.to_s
    @garbage_count = MsgMessage.garbage_count(current_base_user.id).to_s
  end
  
end
