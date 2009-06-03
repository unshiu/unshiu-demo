module ManageMngUserActionHistoriesControllerModule
  
  # GET /manage/mng_user_action_histories
  def index
    @mng_user_action_histories = MngUserActionHistory.find(:all, :order => 'created_at desc',
                                                           :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
  end

  # GET /manage/mng_user_action_histories/1
  def show
    @mng_user_action_history = MngUserActionHistory.find(params[:id])
  end
  
end
