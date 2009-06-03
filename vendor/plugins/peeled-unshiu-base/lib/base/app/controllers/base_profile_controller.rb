module BaseProfileControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required, :except => 'show'
        nested_layout_with_done_layout
      end
    end
  end
  
  def index
    redirect_to :action => :show, :id => current_base_user.id
  end
  
  def show
    @user = BaseUser.find(params[:id])
    
    relation = UserRelationSystem.user_relation(current_base_user, @user.id)
    
    @entries = DiaDiary.find_or_create(@user).accesible_entries(current_base_user).find(:all, :page => {:size => AppResources['dia']['profile_entry_list_size']})
    @albums = AbmAlbum.find_accessible_albums(current_base_user, @user.id, { :order => "updated_at desc", 
                                              :page => {:size => AppResources['abm']['profile_album_list_size']}})
    @profile = @user.base_profile
    
    footmark_user_id = logged_in? ? current_base_user.id : -1
    @footmark = AceFootmark.find_footmark("base_profile#show", footmark_user_id, @user.id)
  end
  
  def mail
    @mail_address = BaseMailerNotifier.mail_address(current_base_user.id, "BaseProfile", "receive", current_base_user.base_profile.id)
  end
  
  def new
    @profile = BaseProfile.new
    @profile.name_public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
  end
  
  def confirm
    @profile = BaseProfile.new(params[:profile])
    
    unless @profile.valid?
      render :action => 'new'
      return
    end
  end

  def create
    @profile = BaseProfile.new(params[:profile])
    if cancel?
      render :action => 'new'
      return
    end
    
    @profile.base_user_id = current_base_user_id
    @profile.save
    
    redirect_to :action => 'done'
  end
  
  def done
  end
  
  def edit
    @profile = BaseProfile.find_by_base_user_id(current_base_user_id)
    @profile.name_public_level = UserRelationSystem::PUBLIC_LEVEL_ALL # FIXME 名前公開固定仕様は要検討
  end
  
  def update_confirm
    @profile = BaseProfile.new(params[:profile])
    
    unless @profile.valid?
      render :action => 'edit'
      return
    end
  end

  def update  
    @profile = BaseProfile.find_by_base_user_id(current_base_user_id)
    @profile.attributes = params[:profile]
      
    if cancel?
      render :action => 'edit'
      return
    end
    
    unless @profile.valid?
      render :action => 'edit'
      return
    end
    @profile.save
    
    if request.mobile?
      redirect_to :action => 'update_done'
    else
      flash[:notice] = t('view.flash.notice.base_profile_update')
      redirect_to :controller => :base_user_config, :action => :index
    end
  end
  
  def update_done
  end
  
  def image
    @base_profile = BaseProfile.find_by_base_user_id(current_base_user_id)
  end
  
  def image_upload
    @base_profile = BaseProfile.find_by_base_user_id(current_base_user_id)
    @base_profile.image = params[:upload_file][:image]
    
    unless @base_profile.valid?
      flash.now[:error] = t('view.flash.error.base_profile_image_update')
      render :action => :image
      return
    end
    @base_profile.save
    
    flash[:notice] = t('view.flash.notice.base_profile_image_update')
    redirect_to :controller => :base_profile, :action => :show, :id => @base_profile.base_user_id
  end
end
