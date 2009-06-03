#
# 管理者画面：メールマガジン管理
#
module ManageMlgControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        # 削除制限
        before_filter :deletable_check, :only => ['delete', 'delete_confirm']
      end
    end
  end
  
  def deletable_check
    target = MlgMagazine.find_by_id(params[:id])
    target = MlgMagazine.find(params[:mlg_magazine][:id]) unless target
    
    if target && target.deletable?
      return true
    else
      redirect_to_error('M-05001')
      return false
    end
  end
  private :deletable_check
  
  # 新規作成
  def new
  end
  
  # 作成確認
  def confirm
    @mlg_magazine = MlgMagazine.new(params[:mlg_magazine])
    
    unless @mlg_magazine.valid?
      render :action => 'new'
      return
    end
  end
  
  # 作成
  def create
    @mlg_magazine = MlgMagazine.new(params[:mlg_magazine])
    
    if cancel?
      render :action => 'new'
      return
    end
    
    if @mlg_magazine.save
      flash[:notice] = "メールマガジンテンプレートを作成しました。"
      redirect_to :action => :list
    else
      flash[:warning] = "メールマガジンテンプレート作成に失敗しました。"
      redirect_to :action => :new
    end
  end
  
  # 表示
  # params[:id] メールマガジンID
  def show
    @mlg_magazine = MlgMagazine.find(params[:id])
    @send_count = MlgDelivery.count_target_delivers(@mlg_magazine.id)
  end
  
  # 履歴
  def list
    @mlg_magazines = MlgMagazine.find(:all, :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]}, :order => ['updated_at DESC'])
  end
  
  # 削除の確認画面
  # _param1_:: params[:id] メルマガID
  def delete_confirm
    @mlg_magazine = MlgMagazine.find(params[:id])
  end
  
  # 削除実行
  def delete
    mlg_magazine = MlgMagazine.find(params[:mlg_magazine][:id])
    
    if cancel?
      redirect_to :action => 'list'
      return
    end
    
    if mlg_magazine.destroy
      flash[:notice] = "メールマガジンを削除しました。"
    else
      flash[:error] = "メールマガジン削除に失敗しました。"
    end
    redirect_to :action => :list
  end
end
