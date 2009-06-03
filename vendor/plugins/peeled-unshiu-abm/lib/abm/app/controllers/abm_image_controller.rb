module AbmImageControllerModule
  
  class << self
    def included(base)
      base.class_eval do  
        before_filter :login_required, :except => ['show', '__mobile_show', 'upload_remote']
        before_filter :access_filter, :only => ['show', '__mobile_show']
        before_filter :owner_only, :except => ["new", "show", "__mobile_show", "delete_done", 'upload_remote', 'upload', 'cover_album_image']
        before_filter :abm_album_owner_required, :only => ["upload"]
        
        protect_from_forgery :except => [:upload_remote]
        
        nested_layout_with_done_layout
      end
    end
  end

  def new
    @abm_album_id = params[:abm_album_id]
  end
  
  def show
    session[:upload_count] = nil
    
    @image = AbmImage.find(params[:id])
    if logged_in?
      @albums = AbmAlbum.find(:all, :conditions =>["base_user_id = ?", current_base_user.id])
    end
    @abm_image_comments = @image.abm_image_comments.recent(AppResources[:abm][:image_comments_list_size_for_abm_image])
    @abm_image_nexts = @image.nexts(AppResources[:abm][:image_list_around_size])
    @abm_image_previouses = @image.previouses(AppResources[:abm][:image_list_around_size])
  end
  
  def __mobile_show
    @image = AbmImage.find(params[:id])
    if logged_in?
      @albums = AbmAlbum.find(:all, :conditions =>["base_user_id = ?", current_base_user.id])
    end
  end
  
  # 削除前の確認画面へ
  def confirm_delete
    @image = AbmImage.find(params[:id])
  end
  
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    
    image = AbmImage.find(params[:id])
    album_id = image.abm_album_id
    
    image.destroy
    
    flash[:notice] = t('view.flash.notice.abm_image_delete')
    if request.mobile?
      redirect_to :action => 'delete_done', :id => album_id
    else
      redirect_to :controller => :abm_album, :action => :show, :id => album_id
    end
    
  end
  
  def delete_done
    @album = AbmAlbum.find(params[:id])
  end

  alias :edit :confirm_delete

  def confirm_edit
    @image = AbmImage.find(params[:id])
    @image.title = params[:image][:title]
    @image.body = params[:image][:body]
    
    unless @image.valid?
      render :action => 'edit'
      return
    end
  end
  
  def update
    @image = AbmImage.find(params[:id])
    @image.attributes = params[:image]
    
    if cancel? || !@image.valid?
      render :action => 'edit'
      return
    end
  
    @image.save
    
    flash[:notice] = t('view.flash.notice.abm_image_update')
    if request.mobile?
      redirect_to :action => 'update_done', :id => @image.id
    else
      redirect_to :action => :show, :id => @image.id
    end
  end
  
  def update_done
    @image = AbmImage.find(params[:id])
  end
  
  def confirm_move_album
    album_id = params["abm_album_id"]
    @album = AbmAlbum.find(album_id)
    @image = AbmImage.find(params[:id])
  end
  
  def move_album
    album_id = params["abm_album_id"]
    @album = AbmAlbum.find(album_id)
    unless @album.mine?(current_base_user.id)
      redirect_to :controller => :base, :action => :error
      return
    end
    
    @image = AbmImage.find(params[:id])
    @image.abm_album_id = @album.id
    @image.save
    
    flash[:notice] = t('view.flash.notice.abm_image_move_album')
    if request.mobile?
      redirect_to :action => 'move_album_done', :id => @image.id
    else
      redirect_to :action => :show, :id => @image.id
    end
  end
  
  def move_album_done
    @image = AbmImage.find(params[:id])
    @album = @image.abm_album
  end
  
  def upload_remote
    abm_album_id = params[:abm_album_id]
    
    session[:upload_count] ||= -1
    session[:upload_count] += 1
      
    @image = AbmImage.new({:abm_album_id => abm_album_id, :swfupload_file => params[:Filedata]})
    
    if @image.save
      render :partial => 'image', :object => @image, :layout=>false, :locals => {:image_counter => session[:upload_count]}
    else
      render :text => "error"
    end
  end
  
  def upload
    @abm_album_id = params[:abm_album_id]
    
    if params[:upload_file].nil?
      flash.now[:error] = t('view.flash.error.abm_image_upload_no_image')
      render :action => :new, :abm_album_id => @abm_album_id
      return
    end
    
    @image = AbmImage.new({:abm_album_id => @abm_album_id, :upload_file => params[:upload_file][:image]})
    if @image.save
      flash[:notice] = t('view.flash.notice.abm_image_upload')
      redirect_to :controller => :abm_album, :action => :show, :id => @abm_album_id
    else
      render :action => :new, :abm_album_id => @abm_album_id
    end
  end
  
  def cover_album_image
    abm_album = AbmImage.find(params[:id]).abm_album
    abm_album.cover_abm_image_id = params[:id]
    abm_album.save
    
    flash[:notice] = t('view.flash.notice.abm_image_cover_album_image')
    redirect_to :action => :show, :id => params[:id]
  end
  
private

  def owner_only
    unless AbmImage.find(params[:id]).mine?(current_base_user_id)
      redirect_to_error("U-02005")
      return false
    end
  end

  def access_filter
    image = AbmImage.find(params[:id])
    album = image.abm_album
    owner_id = album.base_user_id
    public_level = album.public_level

    unless UserRelationSystem.accessible?(current_base_user, owner_id, public_level)
      if logged_in?
        redirect_to_error "U-02006"
      else
        redirect_to :controller => 'base_user', :action => 'login'
      end
      return false
    end
    return true
  end

  # objectにvalid?をかけて、falseならrender_actionをrenderする。
  def valid_check(object, render_action)
    
    unless object.valid?
      render :action =>  render_action
      return
    end
    
  end
  
  def abm_album_owner_required
    unless AbmAlbum.find(params[:abm_album_id]).mine?(current_base_user_id)
      redirect_to_error("U-02001")
      return false
    end
  end
end
