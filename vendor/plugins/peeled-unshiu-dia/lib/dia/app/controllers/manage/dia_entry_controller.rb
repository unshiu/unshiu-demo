module ManageDiaEntryControllerModule
  
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
    @entries = DiaEntry.undraft_entries(:page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end

 def search
    @keyword = params[:keyword]
    @entries = DiaEntry.undraft_entries_keyword_search(@keyword, :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
    render :action => 'list'
  end
  
  def show
    @entry = DiaEntry.find(params[:id])
    @comments = @entry.dia_entry_comments
  end
  
  def delete_confirm
    @entry = DiaEntry.find(params[:id])
  end
  
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    
    entry = DiaEntry.find(params[:id])
    entry.destroy
    
    flash[:notice] = "#{I18n.t('view.noun.dia_entry')}「#{entry.title}」を削除しました。"
    redirect_to :action => 'list'
  end
end
