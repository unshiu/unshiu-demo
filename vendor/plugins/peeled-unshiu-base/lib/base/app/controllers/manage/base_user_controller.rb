module ManageBaseUserControllerModule
  def index
    redirect_to :action => :info
  end
  
  # ユーザ数遷移などの情報
  def info
    @all_user_count = BaseUser.count_all_users
    @withdrawal_user_count = BaseUser.count_by_withdrawal
    @receive_mail_magazine_user_count = BaseUser.count_by_receive_mail_magazine
  end
  
  def sex_graph_tab
    @all_user_count = BaseUser.count_all_users - BaseUser.count_by_withdrawal
    @sex_graph = open_flash_chart_object(250,250, "/manage/base_user/sex_graph", true, '/')
    @count_male = BaseProfile.count_male
    @count_female = BaseProfile.count_female
    render :layout => false
  end
  
  def sex_graph
    data = []
    all_user_count = BaseUser.count_all_users - BaseUser.count_by_withdrawal
    count_male = BaseProfile.count_male
    count_female = BaseProfile.count_female
    
    data << count_male
    data << count_female
    data << all_user_count - ( count_male + count_female )
    
    pie_values = Array.new
    sexs = BaseProfile::SEX.to_a.sort { |a,b| a[0] <=> b[0] }
    sexs.each { |sex| pie_values << sex[1] }
    pie_values << "未設定"
    
    g = Graph.new
    g.pie(60, '#505050', '{font-size: 12px; color: #404040;}')
    g.pie_values(data, pie_values)
    g.pie_slice_colors(%w(#d01fc3 #356aa0 #c79810))
    g.set_tool_tip("#val#人")
    g.title("男女比", '{font-size:18px; color: #d01f3c}' )
    render :text => g.render    
  end
  
  def mail_magazine_graph_tab
    @count_receive = BaseUser.count_by_receive_mail_magazine
    @count_reject = BaseUser.count_by_reject_mail_magazine
    @mail_magazine_graph = open_flash_chart_object(250,250, "/manage/base_user/mail_magazine_graph", true, '/')
    render :layout => false    
  end
    
  def mail_magazine_graph
    data = []
    data << BaseUser.count_by_receive_mail_magazine
    data << BaseUser.count_by_reject_mail_magazine
    
    g = Graph.new
    g.pie(60, '#505050', '{font-size: 12px; color: #404040;}')
    g.pie_values(data, %w(許可 非許可))
    g.pie_slice_colors(%w(#d01fc3 #356aa0 #c79810))
    g.set_tool_tip("#val#%")
    g.title("メルマガ許可比", '{font-size:18px; color: #d01f3c}' )
    render :text => g.render
  end
  
  def civil_graph_tab
    all_user_count = BaseUser.count_all_users - BaseUser.count_by_withdrawal
    @count_married = BaseProfile.count_married
    @count_unmarried = BaseProfile.count_unmarried
    @unsetup_married = all_user_count - @count_unmarried - @count_married
    @civil_graph = open_flash_chart_object(250,250, "/manage/base_user/civil_graph", true, '/')
    render :layout => false    
  end
  
  def civil_graph
    data = []
    all_user_count = BaseUser.count_all_users - BaseUser.count_by_withdrawal
    count_married = BaseProfile.count_married
    count_unmarried = BaseProfile.count_unmarried
    
    data << count_married
    data << count_unmarried
    data << all_user_count - (count_married + count_unmarried)
    
    g = Graph.new
    g.pie(60, '#505050', '{font-size: 12px; color: #404040;}')
    g.pie_values(data, %w(既婚 未婚 未設定))
    g.pie_slice_colors(%w(#d01fc3 #356aa0 #c79810))
    g.set_tool_tip("#val#%")
    g.title("既婚未婚比", '{font-size:18px; color: #d01f3c}' )
    render :text => g.render        
  end
  
  def carrier_graph_tab
    @count_carriers = []
    @carrier_names = []
    carriers = BaseCarrier.find(:all)
    carriers.each do |carrier|
      @count_carriers << carrier.count_base_user
      @carrier_names << carrier.name
    end
    @carrier_graph = open_flash_chart_object(250,250, "/manage/base_user/carrier_graph", true, '/')
    render :layout => false  
  end
  
  def carrier_graph
    data = []
    pie_values = []
    carrires = BaseCarrier.find(:all)
    carrires.each do |carrier|
      data << carrier.count_base_user
      pie_values << carrier.name
    end
    
    g = Graph.new
    g.pie(60, '#505050', '{font-size: 12px; color: #404040;}')
    g.pie_values(data, pie_values)
    g.pie_slice_colors(%w(#d01fc3 #356aa0 #c79810))
    g.set_tool_tip("#val#%")
    g.title("携帯キャリア比", '{font-size:18px; color: #d01f3c}' )
    render :text => g.render
  end
  
  def area_graph_tab
    @count_area = Array.new
    1.upto(BaseProfile::PREFECTURES.size) do |i|
      @count_area << BaseProfile.count_area(i)
    end
    
    @area_graph = open_flash_chart_object(550,250, "/manage/base_user/area_graph", true, '/')
    render :layout => false 
  end
  
  def area_graph
    bar = BarOutline.new(50, '#9933CC', '#8010A0')
    max = 0
    1.upto(BaseProfile::PREFECTURES.size) do |i|
      bar.data << BaseProfile.count_area(i)
      max = BaseProfile.count_area(i) if BaseProfile.count_area(i) > max
    end
    
    values = Array.new
    prefectures = BaseProfile::PREFECTURES.to_a.sort { |a,b| a[0] <=> b[0] }
    prefectures.each { |prefecture| values << prefecture[1] }
    
    g = Graph.new
    g.title("地域比", "{font-size: 15px;}")
    g.data_sets << bar
    g.set_x_labels(values)
    
    g.set_x_label_style(6, '#9933CC', 0,2)
    g.set_y_max(max)
    g.set_y_label_steps(1)
    g.set_y_legend("ユーザ数", 12, "#736AFF")
    
    render :text => g.render
  end
  
  # 検索フォームページ
  def search
    @pnt_masters = PntMaster.find(:all)
    @carriers = BaseCarrier.find(:all)
  end

  # 検索処理実行
  def user_search
    @pnt_master = PntMaster.find(params[:pnt_master][:id]) unless params[:pnt_master].nil?
    
    @base_user_search_form = Forms::BaseUserSearchForm.new
    @base_user_search_form.joined_start_at = params[:joined_start_at]
    @base_user_search_form.joined_end_at = params[:joined_end_at]
    @base_user_search_form.start_age = params[:age][:start]
    @base_user_search_form.end_age = params[:age][:end]
    unless params[:point].nil?
      @base_user_search_form.start_point = params[:point][:start_point]
      @base_user_search_form.end_point = params[:point][:end_point]
    end
    
    unless @base_user_search_form.valid?
      @pnt_masters = PntMaster.find(:all)
      @carriers = BaseCarrier.find(:all)
      render :action => 'search'
      return
    end
    
    # ユーザ情報
    @user_info = Hash.new
    @user_info[:login] = [ params[:user][:login] ] unless params[:user][:login].blank?
    @user_info[:email] = [ params[:user][:email] ] unless params[:user][:email].blank?
    unless params[:base_carrier_id].nil?
      @user_info[:base_carrier_id] = params[:base_carrier_id].keys
      @carriers = BaseCarrier.find(@user_info[:base_carrier_id])
    end
    joined_at = params[:joined_start_at]
    unless joined_at['date(1i)'].blank?
      @user_info[:joined_at_start] = joined_at['date(1i)'] + '-' + joined_at['date(2i)'] + '-' + joined_at['date(3i)'] 
    end
    joined_at = params[:joined_end_at]
    unless joined_at['date(1i)'].blank?
      @user_info[:joined_at_end] = joined_at['date(1i)'] + '-' + joined_at['date(2i)'] + '-' + joined_at['date(3i)'] 
    end
    
    @user_info[:status] = [BaseUser::STATUS_ACTIVE, BaseUser::STATUS_FORBIDDEN,
                           BaseUser::STATUS_WITHDRAWAL, BaseUser::STATUS_FORCED_WITHDRAWAL]
    
    # プロフィール情報
    @profile_info = Hash.new
    @profile_info[:sex] = params[:sex].keys unless params[:sex].nil?
    @profile_info[:area] = params[:area].keys unless params[:area].nil?
    @profile_info[:civil_status] = params[:civil_status].keys unless params[:civil_status].nil?
    @profile_info[:age_start] = params[:age][:start].to_i unless params[:age][:start].blank?
    @profile_info[:age_end] = params[:age][:end].to_i unless params[:age][:end].blank?
    
    # ポイント情報
    @point_info = HashWithIndifferentAccess.new
    if !params[:point].nil? && ( !params[:point][:start_point].blank? || !params[:point][:end_point].blank? )
      @point_info[:pnt_master_id] = @pnt_master.id
      @point_info[:start_point] = params[:point][:start_point]
      @point_info[:end_point] = params[:point][:end_point]
    end
    
    if params[:csv].blank?
      @users = BaseUser.find_users_by_all_search_info(@user_info, @profile_info, @point_info,
                                                      :page => {:size => 30, :current => params[:page]})
      render :action => 'list'
    else
      base_user_file_hitory = BaseUserFileHistory.new
      base_user_file_hitory.base_user_id = current_base_user.id
      base_user_file_hitory.create_csv_file_name
      base_user_file_hitory.save
      
      csv_infos = {}
      csv_infos[:point] = params[:csv_output_point] unless params[:csv_output_point].blank?
      start_csv_output({:user_info => @user_info, :profile_info => @profile_info, 
                        :point_info => @point_info, :base_user_file_history_id => base_user_file_hitory.id })
      flash[:notice] = 'CSVファイルの更新を開始しました。'
      
      redirect_to :action => :search
    end
  end
  
  def show
    @base_user = BaseUser.find_with_deleted(params[:id])
    @profile = BaseProfile.find_with_deleted(:first, :conditions => ["base_user_id = ?", @base_user.id])
  end
  
  def edit
    @base_user = BaseUser.find(params[:id])
    @profile = @base_user.base_profile
  end
  
  def update_confirm
    @base_user = BaseUser.find(params[:id])
    @base_user.attributes = params[:base_user]
    @profile = @base_user.base_profile
    if !@profile.valid? || !@base_user.valid?
      render :action => 'edit'
    end
  end
  
  def update
    @base_user = BaseUser.find(params[:id])
    @base_user.attributes = params[:base_user]
    
    if cancel?
      render :action => :edit
      return
    end
    
    @base_user.save
    flash[:notice] = t('view.flash.notice.base_user_update')
    redirect_to :action => 'show', :id => @base_user.id
  end
  
  # 強制退会
  def withdrawal_confirm
    @base_user = BaseUser.find(params[:id])
    if BaseUserRole.manager?(@base_user) && BaseUserRole.count_manager == 1
      flash[:warning] = "管理者ユーザ全員を退会処理することはできません。このユーザを削除したい場合は別途管理者を設けてから削除してください。"
      redirect_to :action => 'show', :id => @base_user.id
    end
    @profile = @base_user.base_profile
  end
  
  def withdrawal
    user = BaseUser.find(params[:id])
    
    if cancel?
      redirect_to :action => 'show', :id => user.id
      return
    end
    
    user.quitted_at = Time.now
    user.status = BaseUser::STATUS_FORCED_WITHDRAWAL
    user.save
    user.destroy # 退会情報を記録してから論理削除
    
    flash[:notice] = "#{I18n.t('view.noun.base_user')}を強制退会させました。"
    redirect_to :action => 'show', :id => user.id
  end
  
  # ログイン停止
  def forbid_confirm
    @base_user = BaseUser.find(params[:id])
    if BaseUserRole.manager?(@base_user) && BaseUserRole.count_manager == 1
      flash[:warning] = "管理者ユーザ全員をログイン停止にすることはできません。このユーザを停止したい場合は別途管理者を設けてから停止してください。"
      redirect_to :action => 'show', :id => @base_user.id
    end
    @profile = @base_user.base_profile
  end
  
  def forbid
    user = BaseUser.find(params[:id])
    
    if cancel?
      redirect_to :action => 'show', :id => user.id
      return
    end
    
    user.status = BaseUser::STATUS_FORBIDDEN
    user.save
    
    flash[:notice] = "#{I18n.t('view.noun.base_user')}をログイン停止にしました。"
    redirect_to :action => 'show', :id => user.id
  end

  # ログイン停止解除
  def activate_confirm
    @base_user = BaseUser.find(params[:id])
    @profile = @base_user.base_profile
  end
  
  def activate
    user = BaseUser.find(params[:id])
    
    if cancel?
      redirect_to :action => 'show', :id => user.id
      return
    end
    
    user.status = BaseUser::STATUS_ACTIVE
    user.save
    
    flash[:notice] = "#{I18n.t('view.noun.base_user')}のログイン停止を解除しました。"
    redirect_to :action => 'show', :id => user.id
  end  

  # アカウントの復活確認
  def restore_confirm
    @base_user = BaseUser.find_with_deleted(params[:id])
    @profile = BaseProfile.find_with_deleted(:first, :conditions => ["base_user_id = ?", @base_user.id])
  end
  
  # アカウントの復活処理実行
  def restore
    user = BaseUser.find_with_deleted(params[:id])
    
    if cancel?
      redirect_to :action => 'show', :id => user.id
      return
    end
    
    user.attributes = {:status => BaseUser::STATUS_ACTIVE, :deleted_at => nil}
    user.save
    
    base_profile = BaseProfile.find_with_deleted(:first, :conditions => ["base_user_id = ?", user.id])
    base_profile.deleted_at = nil
    base_profile.save
    
    flash[:notice] = t('view.flash.notice.base_user_restore')
    redirect_to :action => 'show', :id => user.id
  end
  
private
  
  def start_csv_output(args)
    MiddleMan.worker(:base_user_file_generate_worker).generate(:args => args)
  end

end
