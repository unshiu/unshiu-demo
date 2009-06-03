module ManageMsgControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    @messages = MsgMessage.undraft_messages(params[:page])
  end

  def sent_list
    @messages = MsgMessage.manager_messages(params[:page])
  end

  def notify_list
    @messages = MsgMessage.notified_messages(params[:page])
  end

  def show
    @message = MsgMessage.find(params[:id])
  end
  
  def delete_confirm
    @message = MsgMessage.find(params[:id])
  end
  
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    message = MsgMessage.find(params[:id])
    message.destroy
    
    flash[:notice] = "#{I18n.t('view.noun.msg_message')}「#{message.title}」を削除しました。"
    redirect_to :action => 'list'
  end

  def new
    @message = MsgMessage.new
    @user = BaseUser.find(params[:id]) if params[:id]
  end
  
  def confirm
    @message = MsgMessage.new(params[:message])
    @user = BaseUser.find(params[:id]) if params[:id]
    unless @message.valid?
      render :action => 'new'
      return
    end
  end
  
  def create
    message = MsgMessage.new(params[:message])
    
    if cancel?
      @message = message
      render :action => 'new'
      return
    end
    
    message.save
    
    msg_sender = MsgSender.new
    msg_sender.base_user_id = current_base_user.id
    msg_sender.msg_message_id = message.id
    msg_sender.save
    
    if params[:id]
      user = BaseUser.find(params[:id])
      msg_receiver = MsgReceiver.new
      msg_receiver.base_user_id = user.id
      msg_receiver.msg_message_id = message.id
      msg_receiver.save
    else
      worker = MiddleMan.worker(:msg_manager_send_worker)
      worker.all_user_send_message(:arg => {:message_id => message.id, :base_user_class => BaseUser.new })
    end
    
    flash[:notice] = "#{I18n.t('view.noun.msg_message')}を送信しました。"
    redirect_to :action => 'list'
  end
end
