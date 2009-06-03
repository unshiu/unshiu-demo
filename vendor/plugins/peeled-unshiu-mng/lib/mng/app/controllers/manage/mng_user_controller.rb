module ManageMngUserControllerModule
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    @users = BaseUser.find(:all, :include => 'base_user_roles', :conditions => "base_user_roles.role = 'manager' and base_user_roles.deleted_at is null")
  end
  
  def new
  end

  def confirm
    @base_user = BaseUser.new(params[:base_user])
    @base_user.joined_at = Time.now
    
    unless @base_user.valid?
      render :action => 'new'
      return
    end
  end
  
  def create
    @base_user = BaseUser.new(params[:base_user])
    @base_user.status = BaseUser::STATUS_ACTIVE
    @base_user.make_activation_code
    
    if cancel?
      render :action => 'new'
      return
    end
    
    unless @base_user.valid?
      render :action => 'new'
      return
    end
    
    @base_user.save
    BaseProfile.create({:base_user_id => @base_user.id})
    BaseUserRole.add_manager(@base_user.id)
    
    flash[:notice] = "#{@base_user.show_name}を#{I18n.t('view.noun.mng_user')}に設定しました。"
    redirect_to :action => 'list'
  end
  
  def delete_confirm
    @base_user = BaseUser.find(params[:id])

    unless BaseUserRole.manager?(@base_user)
      flash[:error] = "指定された#{I18n.t('view.noun.base_user')}は#{I18n.t('view.noun.mng_user')}ではありません。"
      redirect_to :action => 'list'
      return
    end
    
    @profile = @base_user.base_profile
  end

  def delete
    if cancel?
      redirect_to :action => 'list'
      return
    end
    
    user = BaseUser.find(params[:id])
    unless BaseUserRole.manager?(user)
      flash[:error] = "指定された#{I18n.t('view.noun.base_user')}は#{I18n.t('view.noun.mng_user')}ではありません。"
      redirect_to :action => 'list'
      return
    end
    
    BaseUserRole.remove_manager(params[:id])
    
    flash[:notice] = "#{user.show_name}を#{I18n.t('view.noun.mng_user')}から外しました。"
    redirect_to :action => 'list'
  end
end
