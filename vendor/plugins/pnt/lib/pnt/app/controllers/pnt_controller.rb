#
# ポイント系コントローラ
#
module PntControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        before_filter :owner_required, :except => ["index", "__mobile_index"]
        
        nested_layout_with_done_layout
      end
    end
  end
  
  def index
    __base_user_point_
    unless @pnt_points.empty?
      @pnt_histories = PntHistory.find_by_point_histories_with_pagenate(@pnt_points.first.id, AppResources[:pnt][:history_list_size], params[:page])
    end
  end
  
  def __mobile_index
    __base_user_point_
  end
  
  # ポイント履歴表示
  # params[id] pnt_point_id
  def show
    __base_user_point_
    @pnt_histories = PntHistory.find_by_point_histories_with_pagenate(params[:id], AppResources[:pnt][:history_list_size], params[:page])
  end
  
  # モバイルポイント履歴表示
  # params[id] pnt_point_id
  def __mobile_show
    __base_user_point_
    @pnt_histories = PntHistory.find_by_point_histories_with_pagenate(params[:id], AppResources[:pnt][:history_list_size_mobile], params[:page])
  end
  
private
  
  def __base_user_point_
    @all_point = PntPoint.base_user_all_point(current_base_user_id)
    @pnt_points = PntPoint.find_base_user_points(current_base_user_id)
  end
  
  def owner_required
    @pnt_point = PntPoint.find(params[:id])
    if @pnt_point.base_user_id != current_base_user_id
      redirect_to_error('U-07001')
      return
    end
  end
end
