module ManageBaseUserFileHistoryControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    redirect_to :action => :list
  end
  
  def list
    @histories = BaseUserFileHistory.find(:all, :order => 'created_at desc',
                                          :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
  end
  
  def download
    history = BaseUserFileHistory.find(params[:id])
    if history.complated_at?
      send_file(history.file_full_path_name, :type=> history.content_type)
    else
      flash[:error] = 'ファイルが見つかりません。'
      redirect_to :action => :search
    end
  end
  
end
