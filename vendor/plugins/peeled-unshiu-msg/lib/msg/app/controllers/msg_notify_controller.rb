module MsgNotifyControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :receiver_only, :only => ["new", "confirm", "create"]
        
        nested_layout_with_done_layout("msg_application")  
      end
    end
  end
  
  def new
    setup_current_user_box_count
    
    @message = MsgMessage.find(params[:id])
    @notify = MsgNotify.new
  end

  def confirm
    setup_current_user_box_count
     
    @message = MsgMessage.find(params[:id])
    @notify = MsgNotify.new(params[:notify])
    
    unless @notify.valid?
      render :action => 'new'
      return
    end
  end

  def create
    notify = MsgNotify.new(params[:notify])
    
    if cancel?
      @notify = notify
      @message = MsgMessage.find(params[:id])
      setup_current_user_box_count
      render :action => 'new'
      return
    end
    
    notify.msg_message_id = params[:id]
    notify.save
    
    if request.mobile?
      redirect_to :action => 'done'
    else
      flash[:notice] = t('view.flash.notice.notify_msg_message')
      redirect_to :controller => :msg_message, :action => :index
    end
  end
  
  def done
  end
  
end
