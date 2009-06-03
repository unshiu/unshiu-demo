module BaseFriendApplyControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        before_filter :owner_only, :only => ['permit_or_deny', 'deny', 'permit']
        before_filter :my_reject, :only => ['new', 'confirm', 'create']
        nested_layout_with_done_layout
      end
    end
  end
  
  def new
    @user = BaseUser.find(params[:id])
  end
  
  def confirm
    BaseNgWord.find(1).save unless BaseNgWord.find_by_id(1).nil? # ngワードチェック再構築
    
    @user = BaseUser.find(params[:id])
    bfaf = Forms::BaseFriendApplyForm.new
    bfaf.apply_message = params[:apply_message]
    unless bfaf.valid?
      @bfaf = bfaf
      render :action => 'new'
      return
    end
  end

  def create
    @user = BaseUser.find(params[:id])
    
    if cancel?
      render :action => 'new'
      return
    end
    
    @base_friend_apply_form = Forms::BaseFriendApplyForm.new
    @base_friend_apply_form.apply_message = params[:apply_message]
    unless @base_friend_apply_form.valid?
      render :action => 'new'
      return
    end
    
    result = BaseFriend.add(current_base_user.id, @user.id, BaseFriend::STATUS_APPLYING)
    if result.is_a?(String)
      redirect_to_error(result)
      return
    end
    
    BaseMailerNotifier.deliver_friend_apply_message(result, @base_friend_apply_form.apply_message)
    
    flash[:notice] = t('view.flash.notice.base_friend_apply_create')
    if request.mobile?
      redirect_to :action => 'done', :id => @user.id
    else
      redirect_to :action => 'list'
    end
  end
  
  def done
    @user = BaseUser.find(params[:id])
  end
  
  def permit_or_deny
    @apply = BaseFriend.find(params[:id])
  end
  
  def permit_confirm
    if params[:deny]
      redirect_to :action => 'deny_confirm', :id => params[:id]
      return
    end
    @apply = BaseFriend.find_by_id(params[:id])
    if @apply.nil? || !@apply.applying?
      redirect_to_error('U-01009')
      return
    end    
  end
  
  def permit
    if cancel?
      redirect_to :action => 'permit_or_deny', :id => params[:id]
      return
    end
    
    friend = BaseFriend.find(params[:id])
    friend.permit
  
    flash[:notice] = t('view.flash.notice.base_friend_apply_permit')
    if request.mobile?
      redirect_to :action => 'permit_done', :id => friend.base_user_id
    else
      redirect_to :action => 'list'
    end
  end

  def permit_done
    @user = BaseUser.find(params[:id])
  end
  
  def deny_confirm
    @apply = BaseFriend.find_by_id(params[:id])    
    if @apply.nil? || !@apply.applying?
      redirect_to_error('U-01008')
      return
    end
  end
  
  def deny
    if cancel?
      redirect_to :action => 'permit_or_deny', :id => params[:id]
      return
    end
    
    friend = BaseFriend.find(params[:id])
    friend.deny
    
    flash[:notice] = t('view.flash.notice.base_friend_apply_deny')
    if request.mobile?
      redirect_to :action => 'deny_done', :id => friend.base_user_id
    else
      redirect_to :action => 'list'
    end
  end
  
  def deny_done
    @user = BaseUser.find(params[:id])
  end
  
  def list
    @applied_list = current_base_user.friend_applies.find(:all, :page => {:size => AppResources["base"]["friend_list_size"], :current => params[:page]})
  end
  
  private
    def owner_only
      friend = BaseFriend.find(params[:id])
      unless friend
        redirect_to_error('U-01007')
      end
      unless friend.friend_id == current_base_user_id
        redirect_to_error('U-01007')
      end
    end
  
    def my_reject
      if current_base_user_id == params[:id].to_i
        redirect_to_error('U-01006')
      end
    end
  
end
