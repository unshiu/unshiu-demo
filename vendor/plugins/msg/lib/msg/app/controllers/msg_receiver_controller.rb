module MsgReceiverControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :receiver_only, :only => ["show", "__mobile_show", "delete_confirm", "delete", "restore", "restore_confirm",
                                                "delete_completely", "delete_completely_confirm", "__mobile_delete_completely_confirm"]
                                                
        before_filter :receive_messages_owner_required, :only => ["delete_messages_remote", "read_messages_remote", "unread_messages_remote"]
        before_filter :receive_messages_owner_required_for_mobile, :only => ["__mobile_delete_messages", "delete_messages_confirm"]
        
        base.nested_layout_with_done_layout("msg_application")
      end
    end
  end
  
  def list
    current_user = BaseUser.find(current_base_user.id)
    key = Util.resources_keyname_from_device("message_list_size", request.mobile?)
    @messages = current_user.msg_receive_messages.find(:all, :order => "id desc",
                                                       :page=>{:size => AppResources["msg"][key], :current => params[:page]})
  end

  def show
    setup_current_user_box_count
    @message = MsgMessage.find(params[:id])
    @message.msg_receiver(current_base_user.id).read
    
    base_user = BaseUser.find(current_base_user.id)
    @next_message = base_user.msg_receive_messages.next_message(@message.id).first
    @prev_message = base_user.msg_receive_messages.prev_message(@message.id).first
  end

  def __mobile_show
    @message = MsgMessage.find(params[:id])

    @message.msg_receiver(current_base_user.id).read
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
    msg_receiver = message.msg_receivers.find(:first, :conditions => ["base_user_id = ?", current_base_user.id])
    msg_receiver.into_trash_box

    if request.mobile?
      redirect_to :controller => 'msg_message', :action => 'delete_done'
    else
      flash[:notice] = t('view.flash.notice.into_trash_msg_message')
      redirect_to :controller => 'msg_message', :action => 'index'
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
  
  def delete_messages_remote
    MsgReceiver.delete_messages(current_base_user.id, params[:message_ids])
    
    current_user = BaseUser.find(current_base_user.id)
    @messages = current_user.msg_receive_messages.find(:all, :page=>{:size => AppResources[:msg][:message_list_size], :current => params[:page]})
  end
  
  def __mobile_delete_messages
    if cancel?
      redirect_to :action => 'list'
      return
    end
    
    MsgReceiver.delete_messages(current_base_user.id, params[:del].keys)
    redirect_to :controller => 'msg_message', :action => 'delete_done'
  end
  
  # メッセージを既読にする RJS用
  def read_messages_remote
    msg_messages = MsgMessage.find(params[:message_ids])
    MsgMessage.transaction do
      msg_messages.each do |message|
        receiver = message.msg_receiver(current_base_user.id)
        receiver.read_flag = true
        receiver.save!
      end
    end
    current_user = BaseUser.find(current_base_user.id)
    @messages = current_user.msg_receive_messages.find(:all, :page=>{:size => AppResources[:msg][:message_list_size], :current => params[:page]})
  end
  
  # メッセージを未読にする RJS用
  def unread_messages_remote
    msg_messages = MsgMessage.find(params[:message_ids])
    MsgMessage.transaction do 
      msg_messages.each do |message|
        receiver = message.msg_receiver(current_base_user.id)
        receiver.read_flag = false
        receiver.save!
      end
    end
    current_user = BaseUser.find(current_base_user.id)
    @messages = current_user.msg_receive_messages.find(:all, :page=>{:size => AppResources[:msg][:message_list_size], :current => params[:page]})
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
    msg_receiver = message.msg_receivers.find(:first, :conditions => ["base_user_id = ?", current_base_user.id])
    msg_receiver.restore

    flash[:notice] = t('view.flash.notice.msg_receiver_restore')
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
    msg_receiver = message.msg_receivers.find(:first, :conditions => ["base_user_id = ?", current_base_user.id])
    msg_receiver.delete_completely

    if request.mobile?
      redirect_to :controller => 'msg_message', :action => 'delete_completely_done'
    else
      flash[:notice] = t('view.flash.notice.delete_msg_message')
      redirect_to :controller => 'msg_message', :action => 'garbage_list'
    end
  end
  
end