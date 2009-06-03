module BaseFavoriteControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        before_filter :my_reject, :only => ['add_confirm', 'add']
        nested_layout_with_done_layout
      end
    end
  end
  
  def list
    @favorites = current_base_user.favorites.find(:all, :page => {:size => AppResources["base"]["favorite_list_size"], :current => params[:page]})
  end
  
  def add_confirm
    @user = BaseUser.find(params[:id])
  end
  
  def add
    if cancel?
      redirect_to :controller => 'base_profile', :action => 'show', :id => params[:id]
      return
    end
    
    result = BaseFavorite.add(current_base_user.id, params[:id])
    if result.is_a?(String)
      redirect_to_error(result)
      return
    end
    
    flash[:notice] = t('view.flash.notice.base_favorite_add')
    if request.mobile?
      redirect_to :action => 'add_done', :id => params[:id]
    else
      redirect_to :action => 'list'
    end
  end
  
  def add_done
    @user = BaseUser.find(params[:id])
  end

  def delete_confirm
    @favorite = BaseFavorite.find_by_ids(current_base_user.id, params[:id])
    if @favorite.nil? # 関係がまだない
      redirect_to_error("U-01003")
      return
    end
  end
  
  def delete
    if cancel?
      redirect_to :action => 'list'
      return
    end
    
    favorite = BaseFavorite.find_by_id(params[:id])
    if favorite.nil?
      redirect_to_error("U-01022")
      return
    end
    
    favorite.destroy
    
    flash[:notice] = t('view.flash.notice.base_favorite_delete')
    if request.mobile?
      redirect_to :action => 'delete_done', :id => favorite.favorite.id
    else
      redirect_to :action => 'list'
    end
  end
  
  def delete_done
    @user = BaseUser.find(params[:id])
  end
  
  private
  
    def my_reject
      if current_base_user_id == params[:id].to_i
        redirect_to_error('U-01005')
      end
    end
end
