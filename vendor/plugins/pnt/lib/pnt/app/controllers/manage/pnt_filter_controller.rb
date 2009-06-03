#
# 管理者画面：ポイントフィルター管理
#
module ManagePntFilterControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # 新規作成
  def new
    @pnt_filter = PntFilter.new
    @pnt_filter.pnt_master_id = params[:pnt_master_id]
    @pnt_filter_masters = PntFilterMaster.find(:all)
  end
  
  # 作成確認
  def confirm
    @pnt_filter = PntFilter.new(params[:pnt_filter])
    
    unless @pnt_filter.valid?
      @pnt_filter_masters = PntFilterMaster.find(:all)
      render :action => 'new'
      return
    end
  end
  
  # 作成処理
  def create
    pnt_filter = PntFilter.new(params[:pnt_filter])
    
    if cancel?
      @pnt_filter = pnt_filter
      @pnt_filter_masters = PntFilterMaster.find(:all)
      render :action => 'new'
      return
    end
    
    if pnt_filter.save
      flash[:notice] = "#{I18n.t('view.noun.pnt_filter')}情報を追加しました"
      redirect_to :controller => :pnt_master, :action => :show, :id => pnt_filter.pnt_master_id
    else
      redirect_to :action => :new
    end
  end
  
  def show
    @pnt_filter = PntFilter.find(params[:id])
  end
  
  # 編集
  # params[id] ポイントフィルタID
  def edit
    @pnt_filter = PntFilter.find(params[:id])
    @pnt_filter_masters = PntFilterMaster.find(:all)
  end
  
  # 編集確認
  def update_confirm
    @pnt_filter = PntFilter.new(params[:pnt_filter])
    @pnt_filter.id = params[:pnt_filter][:id]
    unless @pnt_filter.valid?
      @pnt_filter_masters = PntFilterMaster.find(:all)
      render :action => 'edit'
      return
    end
  end
  
  # 更新実行
  def update
    if cancel?
      redirect_to :action => :show, :id => params[:pnt_filter][:id]
      return
    end
    
    pnt_filter = PntFilter.find(params[:pnt_filter][:id])
    if pnt_filter.update_attributes(params[:pnt_filter])
      flash[:notice] = "#{I18n.t('view.noun.pnt_filter')}情報を更新しました"
      redirect_to :controller => :pnt_master, :action => :show, :id => pnt_filter.pnt_master_id
    else 
      flash[:error] = "#{I18n.t('view.noun.pnt_filter')}情報の更新に失敗しました"
      redirect_to :action => :edit
    end
  end
  
  #　フィルタの削除確認
  def delete_confirm
    @pnt_filter = PntFilter.find(params[:id])
  end
  
  # フィルタの削除
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:pnt_filter][:id]
      return
    end
    
    pnt_filter = PntFilter.find(params[:pnt_filter][:id])
    if pnt_filter.destroy
      flash[:notice] = "#{I18n.t('view.noun.pnt_filter')}情報を削除しました"
      redirect_to :controller => :pnt_master, :action => :show, :id => pnt_filter.pnt_master_id
    else
      flash[:error] = "#{I18n.t('view.noun.pnt_filter')}の削除に失敗しました"
      redirect_to :action => :new
    end
  end 
end