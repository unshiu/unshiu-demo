module ManageAbmImageControllerModule
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
    @images = AbmImage.find(:all, :order => 'updated_at desc',
      :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end

  def show
    @image = AbmImage.find(params[:id])
  end
  
  alias :delete_confirm :show
  
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    
    image = AbmImage.find(params[:id])
    image.destroy
    
    flash[:notice] = "#{I18n.t('view.noun.abm_image')}「#{image.title}」を削除しました。"
    redirect_to :controller => 'manage/abm_album', :action => 'show', :id => image.abm_album_id
  end
end
