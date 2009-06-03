module BaseFriendControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        before_filter :owner_only, :only => ['delete']
        before_filter :my_reject, :only => ['add_confirm', 'add']
        nested_layout_with_done_layout
      end
    end
  end
  
  def list
    id = params[:id]
    unless id
      @user = current_base_user
    else
      @user = BaseUser.find(id)
    end
    @friends = @user.friends.find(:all, :page => {:size => AppResources["base"]["friend_list_size"], :current => params[:page]})
  end
  
  def add_confirm
    @user = BaseUser.find(params[:id])
  end
  
  def add
    result = BaseFriend.add(current_base_user.id, params[:id])
    if result.is_a?(String)
      redirect_to_error(result)
      return
    end
    
    BaseFriend.add(params[:id], current_base_user.id)
    
    redirect_to :action => 'add_done', :id => params[:id]
  end

  def add_done
    @user = BaseUser.find(params[:id])
  end

  def delete_confirm
    @friend = BaseFriend.find_friend(current_base_user.id, params[:id])
    redirect_to_error('U-01014') unless @friend
  end
  
  def delete
    friend = BaseFriend.find(params[:id])
    
    if cancel?
      redirect_to :action => 'list'
      return
    end
    
    friend.find_reverse.destroy
    friend.destroy
    
    flash[:notice] = t('view.flash.notice.base_friend_delete')
    if request.mobile?
      redirect_to :action => 'delete_done', :id => friend.friend.id
    else
      redirect_to :action => :list
    end
  end
  
  def delete_done
    @user = BaseUser.find(params[:id])
  end
  
  private
    def owner_only
      friend = BaseFriend.find(params[:id])
      unless friend
        redirect_to_error('U-01013')
      end
      if friend.base_user_id != current_base_user_id && friend.friend_id != current_base_user_id
        redirect_to_error('U-01014')
      end
    end
  
   def my_reject
      if current_base_user_id == params[:id].to_i
        redirect_to_error('U-01012')
      end
    end
    
end