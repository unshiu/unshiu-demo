module ManageAbmAlbumControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    @albums = AbmAlbum.find(:all, :order => 'updated_at desc',
      :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end

  def show
    @album = AbmAlbum.find(params[:id])
  end
  
  def delete_confirm
    @album = AbmAlbum.find(params[:id])
  end
  
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    
    album = AbmAlbum.find(params[:id])
    album.destroy
    
    flash[:notice] = "#{I18n.t('view.noun.abm_album')}「#{album.title}」を削除しました。"
    redirect_to :action => 'list'
  end
end
