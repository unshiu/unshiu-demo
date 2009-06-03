#
# 管理者画面：ポイントマスタ管理
#
module ManagePntMasterControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        # 削除制限
        before_filter :deletable_check, :only => ['delete', 'delete_confirm']
      end
    end
  end
  
  def deletable_check
    target = PntMaster.find_by_id(params[:id])
    target = PntMaster.find(params[:pnt_master][:id]) unless target
    
    if target && target.pnt_points.empty?
      return true
    else
      redirect_to_error('M-07001')
      return false
    end
  end
  private :deletable_check
  
  # 新規作成
  def new
  end
    
  #　作成確認
  def confirm
    @pnt_master = PntMaster.new(params[:pnt_master])
    
    unless @pnt_master.valid?
      render :action => 'new'
      return
    end
  end
  
  # 作成処理
  def create
    pnt_master = PntMaster.new(params[:pnt_master])
    
    if cancel?
      @pnt_master = pnt_master
      render :action => 'new'
      return
    end
    
    if pnt_master.save
      flash[:notice] = "#{I18n.t('view.noun.pnt_master')}情報を追加しました"
      redirect_to :action => :list
    else
      redirect_to :action => :new
    end
  end
  
  # 編集
  # params[id] ポイントマスタID
  def edit
    @pnt_master = PntMaster.find(params[:id])
  end
  
  # 編集確認
  def update_confirm
    @pnt_master = PntMaster.find(params[:pnt_master][:id])
    @pnt_master.title = params[:pnt_master][:title]

    unless @pnt_master.valid?
      render :action => 'edit'
      return
    end
  end
  
  #　更新処理実行
  def update
    pnt_master = PntMaster.find(params[:pnt_master][:id])
    
    if cancel?
      @pnt_master = pnt_master
      @pnt_master.attributes = params[:pnt_master]
      render :action => 'edit'
      return
    end
    
    if pnt_master.update_attributes(params[:pnt_master])
      flash[:notice] = "#{I18n.t('view.noun.pnt_master')}情報を更新しました"
      redirect_to :action => :list
    else
      flash[:error] = "#{I18n.t('view.noun.pnt_master')}情報の更新に失敗しました"
      redirect_to :action => :edit
    end
  end
  
  # 一覧
  def list
    @pnt_masters = PntMaster.find(:all, :page => {:size => 30, :current => params[:page]})
  end
  
  # 個別表示
  # params[id] 表示するポイントマスタID
  def show
    @pnt_master = PntMaster.find(params[:id])
    @pnt_filters = PntFilter.find_pnt_master_filters(@pnt_master.id)
  end
  
  # 削除確認
  # params[id] ポイントマスタID
  def delete_confirm
    @pnt_master = PntMaster.find(params[:id])
  end
  
  #　削除実行
  def delete
    @pnt_master = PntMaster.find(params[:pnt_master][:id])
    
    if cancel?
      redirect_to :action => 'show', :id => @pnt_master.id
      return
    end
    
    if @pnt_master.destroy
      flash[:notice] = "#{I18n.t('view.noun.pnt_master')}情報を削除しました"
    else
      flash[:error] = "#{I18n.t('view.noun.pnt_master')}情報の削除に失敗しました"
    end
    redirect_to :action => :list
  end
end