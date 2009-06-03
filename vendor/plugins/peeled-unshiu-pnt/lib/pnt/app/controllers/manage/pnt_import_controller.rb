#
# 管理者画面：ポイント一括登録管理
#
module ManagePntImportControllerModule

  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # 一括登録
  def new
  end

  # 一括登録確認
  def confirm
  end
  
  # 登録履歴
  def list
    @pnt_file_update_histories = PntFileUpdateHistory.find(:all, :order => 'created_at desc', 
                                                                 :page => {:size => 30, :current => params[:page]})
  end
  
  # ファイルのアップロード処理
  def upload
    @pnt_import_form = Forms::PntImportForm.new({:import_file => params[:file]})
    
    unless @pnt_import_form.valid?
      render :action => :new
      return
    end
    
    flash[:notice] = t('view.flash.notice.pnt_import_upload')
    render :action => :confirm
  end
  
  # 処理を追加
  def add_process
    if cancel?
      redirect_to :action => 'list'
      return
    end
    
    file_name = params[:pnt_import][:file_name]
    MiddleMan.new_worker(:class => :pnt_import_worker, :args => file_name)
    
    flash[:notice] = "処理完了後に管理者宛にメールを送信します。"
    redirect_to :action => :new
  end
  
end
