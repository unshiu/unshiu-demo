require 'fileutils'

module AbmAlbumControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required, :except => ['show', 'list', 'friend_list', 'public_list']
        before_filter :access_filter, :only => ['show']
        before_filter :owner_only, :except => ["show",  "list",   'friend_list', 'public_list',
                                               'index', 'create', 'new',  'confirm',  'delete_done']
                                               
        nested_layout_with_done_layout
      end
    end
  end
  
  def index
    key = Util.resources_keyname_from_device("album_list_size", request.mobile?)
    @albums = current_base_user.abm_albums.find(:all, :order => "updated_at desc", 
                                                :page => {:size => AppResources[:abm][key], :current => params[:page]})
  end
  
  def show
    @album = AbmAlbum.find(params[:id])
    key = Util.resources_keyname_from_device("image_list_size", request.mobile?)
    @images = @album.abm_images.find(:all, :page => {:size => AppResources[:abm][key], :current => params[:page]}, :order => "created_at desc")
  end
  
  def new
    @album = AbmAlbum.new
  end
  
  def confirm
    @album = AbmAlbum.new(params[:album])
    unless @album.valid?
      render :action => 'new'
      return
    end
  end
  
  def create
    @album = AbmAlbum.new(params[:album])
    @album.base_user_id = current_base_user.id
    
    if cancel?
      render :action => 'new'
      return
    end
    
    unless @album.valid?
      render :action => 'new'
      return
    end
    
    @album.save
    
    flash[:notice] = t('view.flash.notice.abm_album_create')
    if request.mobile?
      redirect_to :action => 'done', :id => @album.id
    else
      redirect_to :action => 'index'
    end
  end
  
  def done
    @album = AbmAlbum.find(params[:id])
  end
  
  alias :edit :done
  
  def update_confirm
    @album = AbmAlbum.new(params[:album])
    unless @album.valid?
      render :action => 'edit'
      return
    end
  end
  
  def update
    album = AbmAlbum.find(params[:id])

    if cancel?
      @album = AbmAlbum.new(params[:album])
      render :action => 'edit'
      return
    end
    
    album.update_attributes(params[:album])
    flash[:notice] = t('view.flash.notice.abm_album_update')
    if request.mobile
      redirect_to :action => 'update_done', :id => album.id
    else
      redirect_to :action => 'index'
    end
  end
  
  alias :update_done :done
  # FIXME delete_confirm とするべき
  alias :confirm_delete :done
  
  def delete
    if cancel?
      params[:cancel_to] ||= url_for(:action => 'show', :id => params[:id])
      cancel_to_return
      return
    end
    
    @album = AbmAlbum.destroy(params[:id])
    flash[:notice] = t('view.flash.notice.abm_album_delete')
    if request.mobile?
      redirect_to :action => 'delete_done', :id => @album.id
    else
      redirect_to :action => 'index'
    end
  end
  
  def delete_done
    @album = AbmAlbum.find_with_deleted(:first, :conditions => ['id = ?', params[:id]])
  end

  def list
    @user = BaseUser.find(params[:id])
    @albums = AbmAlbum.find_accessible_albums(current_base_user, params[:id],
                                             {:page => {:size => AppResources['abm']['album_list_size'], :current => params[:page]}, 
                                              :order => "updated_at desc"})
  end

  def friend_list
    key = Util.resources_keyname_from_device("album_list_size", request.mobile?)
    @albums = AbmAlbum.friend_albums(current_base_user, :page => {:size => AppResources[:abm][key], :current => params[:page]})
  end

  def public_list
    key = Util.resources_keyname_from_device("album_list_size", request.mobile?)
    @albums = AbmAlbum.public_albums(:page => {:size => AppResources[:abm][key], :current => params[:page]})
  end
  
  def show_address
    @address = BaseMailerNotifier.mail_address(
      current_base_user.id, AbmAlbum.class_name, 'save_with_mail', params[:id])
  end

private

  # params[:id] の id を持つ AbmAlbum の所有者でなければエラーページに遷移
  def owner_only
    unless AbmAlbum.find(params[:id]).mine?(current_base_user_id)
      redirect_to_error("U-02001")
      return false
    end
  end

  def access_filter
    album = AbmAlbum.find(params[:id])
    owner_id = album.base_user_id
    public_level = album.public_level
    unless UserRelationSystem.accessible?(current_base_user, owner_id, public_level)
      if logged_in?
        redirect_to_error "U-02002"
      else
        redirect_to :controller => 'base_user', :action => 'login'
      end
      return false
    end
    return true
  end
  
end
