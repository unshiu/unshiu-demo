#
# 管理者画面：ポイント管理
#
module ManagePntControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # ユーザのポイント履歴
  # params[:id] 表示したいユーザのID
  def user_history
    user_id = params[:id]
    @base_user = BaseUser.find_with_deleted(user_id)
    @base_user_point = PntPoint.base_user_all_point(user_id)
    pnt_points = PntPoint.find_base_user_points(user_id)
    
    unless pnt_points.nil?
      pnt_points.each { |pnt_point| 
        histories = PntHistory.find_by_point_histories(pnt_point.id)
        @point_histories.nil? ? @point_histories = histories : @point_histories << histories
      }
      @point_histories.flatten! if @point_histories
    end
     
    @pnt_masters = PntMaster.find(:all)
    @pnt_filter_masters = PntFilterMaster.find(:all)
  end
  
  # ユーザのポイント履歴追加の確認
  def confirm
    @pnt_history = PntHistory.new(params[:pnt_history])
    @pnt_master = PntMaster.find(params[:pnt_master][:id])
    @base_user = BaseUser.find(params[:base_user][:id])
    
    unless @pnt_history.valid?
      params[:id] = params[:base_user][:id]
      user_history
      render :action => 'user_history'
      return
    end
    
    if @pnt_master.nil? or @base_user.nil?
      flash[:error] = "正常に処理できませんでした"
      redirect_to :action => :user_history, :id => params[:base_user][:id]
      return 
    end
    
    pnt_point = PntPoint.find_base_user_point(@pnt_master.id, @base_user.id)
    if pnt_point.nil? 
      pnt_point = PntPoint.base_create_new(@pnt_master.id, @base_user.id)
      pnt_point.save
    end
    
    pnt_point.point += @pnt_history.difference
    unless pnt_point.valid?
      redirect_to :action => :user_history, :id => params[:base_user][:id]
      return
    end
    
    @pnt_history.pnt_point_id = pnt_point.id
  end
  
  # ユーザのポイント履歴処理追加
  def create
    if cancel?
      redirect_to :action => :user_history, :id => params[:base_user][:id]
      return
    end
    
    pnt_history = PntHistory.new(params[:pnt_history])
    pnt_master = PntMaster.find(params[:pnt_master][:id])
    base_user = BaseUser.find(params[:base_user][:id])
    
    pnt_point = PntPoint.find_base_user_point(pnt_master.id, base_user.id)
    pnt_point.point += pnt_history.difference
    unless pnt_point.valid?
      redirect_to :action => :user_history, :id => params[:base_user][:id]
      return
    end
    pnt_history.pnt_point_id = pnt_point.id
    pnt_history.amount = pnt_point.point
    
    begin
      PntPoint.transaction do 
        pnt_point.save!
        pnt_history.save!
      end
      flash[:notice] = t('view.flash.notice.manage_pnt_create')
    rescue => e
      logger.error "point history create error!: #{e}"
      flash[:error] = t('view.flash.error.manage_pnt_create')
    end
    redirect_to :action => :user_history, :id => params[:base_user][:id]
  end
  
  # 月別のポイント履歴
  def month_history
    @sum_issue_point = PntHistory.sum_issue_point
    @sum_use_point = PntHistory.sum_use_point
    
    @month_summaries = PntHistorySummary.find_by_month_summaries
  end
  
  # 結果CSVファイルをダウンロード
  # ファイル名はわかりやすいように 対象開始日-対象終了日.csv にする
  # params[:id]　ポイント履歴サマリID
  def export
    summary = PntHistorySummary.find(params[:id])
    send_file summary.file_path, :type => "text/csv;charset=Shift-JIS", :filename => "#{summary.start_at.strftime("%Y%m%d")}-#{summary.end_at.strftime("%Y%m%d")}.csv"
  end
end