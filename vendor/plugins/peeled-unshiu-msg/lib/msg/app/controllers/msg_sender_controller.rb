module MsgSenderControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :sender_only, :only => ["show", "__mobile_show", "delete_confirm", "delete", "restore", "restore_confirm",
                                                "delete_completely", "delete_completely_confirm", "__mobile_delete_completely_confirm"]
        before_filter :send_messages_only, :only => ["delete_messages", "delete_messages_confirm"]
        
        nested_layout_with_done_layout("msg_application")  
      end
    end
  end
  
  def list
    setup_current_user_box_count
    
    @messages = current_base_user.msg_send_messages.find(:all, :order => ["id desc"],
                                                         :page=>{:size => AppResources[:msg][:message_list_size], :current => params[:page]})
  end
  
  def __mobile_list
    @messages = current_base_user.msg_send_messages.find(:all, :order => ["id desc"],
                                                         :page=>{:size => AppResources[:msg][:message_list_size_mobile], :current => params[:page]})
  end

  def show
    setup_current_user_box_count
    
    @message = MsgMessage.find(params[:id])
    @next_message = current_base_user.msg_send_messages.next_message(@message.id).first
    @prev_message = current_base_user.msg_send_messages.prev_message(@message.id).first
  end
  
  def __mobile_show
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
    msg_sender = message.msg_sender
    msg_sender.into_trash_box
    
    if request.mobile?
      redirect_to :controller => 'msg_message', :action => 'delete_done'
    else
      flash[:notice] = t('view.flash.notice.into_trash_msg_message')
      redirect_to :controller => 'msg_sender', :action => 'list'
    end
  end
  
  def delete_messages_confirm
    unless params[:del]
      flash[:error] = "先に#{I18n.t('view.noun.msg_message')}を選択してください。"
      redirect_to :action => 'list'
      return
    end
    
    @messages = MsgMessage.find(params[:del].keys)
  end

  def delete_messages
    if cancel?
      redirect_to :action => 'list'
      return
    end
    
    MsgSender.delete_messages(current_base_user.id, params[:del].keys)
    redirect_to :controller => 'msg_message', :action => 'delete_done'
  end
  
  def delete_messages_remote
    unless params[:message_ids]
      @error_message = t('view.flash.error.delete_messages_remote_no_check')
      render "delete_messages_remote_error"
      return
    end
    
    params[:message_ids].each do |message_id|
      message = MsgMessage.find(message_id)
      if message.msg_sender.base_user_id == current_base_user.id
        message.msg_sender.into_trash_box
      else
        @error_message = t('view.flash.error.delete_messages_remote_no_sender')
        render "delete_messages_remote_error"
        return
      end
    end
    @messages = current_base_user.msg_send_messages.find(:all, :order => ["id desc"],
                                                         :page=>{:size => AppResources[:msg][:message_list_size], :current => params[:page]})
  end
  
  def restore_confirm
    @message = MsgMessage.find(params[:id])
  end
  
  def restore
    if cancel?
      redirect_to :controller => 'msg_message', :action => 'garbage_show', :id => params[:id]
      return
    end
    
    message = MsgMessage.find(params[:id])
    msg_sender = message.msg_sender
    msg_sender.restore
    
    flash[:notice] = t('view.flash.notice.msg_sender_restore')
    if request.mobile?
      redirect_to :controller => 'msg_message', :action => 'restore_done'
    else
      redirect_to :controller => 'msg_message', :action => 'garbage_list'
    end
  end
  
  def delete_completely_confirm
    setup_current_user_box_count
    @message = MsgMessage.find(params[:id])
  end
  
  def __mobile_delete_completely_confirm
    @message = MsgMessage.find(params[:id])
  end
  
  def delete_completely
    if cancel?
      redirect_to :controller => 'msg_message', :action => 'garbage_show', :id => params[:id]
      return
    end
    
    message = MsgMessage.find(params[:id])
    msg_sender = message.msg_sender
    msg_sender.delete_completely
    
    if request.mobile?
      redirect_to :controller => 'msg_message', :action => 'delete_completely_done'
    else
      flash[:notice] = t('view.flash.notice.delete_msg_message')
      redirect_to :controller => 'msg_message', :action => 'garbage_list'
    end
  end  
  
end
