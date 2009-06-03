module BaseInviteControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        nested_layout_with_done_layout
      end
    end
  end
  
  def new
  end

  def confirm
    @mail_address = params[:mail_address]
    @invite_message = params[:invite_message]

    maf = Forms::BaseInviteForm.new
    maf.mail_address = @mail_address
    maf.invite_message = @invite_message
    unless maf.valid?
      @maf = maf
      render :action => 'new'
      return
    end
  end

  def create
    @mail_address = params[:mail_address]
    @invite_message = params[:invite_message]
    
    if cancel?
      render :action => 'new'
      return
    end
    
    current_base_user.invite_friend(@mail_address, @invite_message)
    
    redirect_to :action => 'done', :mail_address => @mail_address
  end
  
  def done
    @mail_address = CGI::unescape(params[:mail_address])
  end
end
