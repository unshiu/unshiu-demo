#
# 管理画面：ユーザのアクティブ率
#
module ManageBaseActiveHistoriesControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    before_day = params[:id] ? params[:id] : BaseActiveHistory::BEFORE_DAYS_LIST[0]
    @base_active_histories = BaseActiveHistory.before(before_day).find(:all, :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
    @active_history_graph = open_flash_chart_object(600,250, "/manage/base_active_histories/active_history_graph?before_days=#{before_day}&page=#{params[:page]}", true, '/')
  end
  
  def active_history_graph
    data_1 = Line.new(2, '#9933CC')
    data_1.key('アクティブユーザ数', 10)

    base_active_histories = BaseActiveHistory.before(params[:before_days]).find(:all, :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
    
    max_count = 0
    dates = []
    base_active_histories.each do |base_active_history|
      dates << base_active_history.history_day.strftime("%m-%d")
      data_1.add_data_tip(base_active_history.user_count,  base_active_history.history_day.strftime("%m-%d"))

      max_count = base_active_history.user_count if max_count < base_active_history.user_count
    end    
    
    g = Graph.new
    g.title("アクティブユーザ数", "{font-size: 20px; color: #736AFF}")
    g.data_sets << data_1

    g.set_tool_tip('#x_label# [#val#]')
    g.set_x_labels(dates)
    g.set_x_label_style(10, '#000000', 0, 2)

    g.set_y_max(max_count)
    g.set_y_label_steps(4)

    render :text => g.render
  end
end