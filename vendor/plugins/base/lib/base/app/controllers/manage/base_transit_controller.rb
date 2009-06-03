module ManageBaseTransitControllerModule
  
  def user
    @base_transit_form = Forms::BaseTransitForm.new(params[:type], params[:date], params[:csv])
    
    unless @base_transit_form.valid? 
      render :action => 'index'
      return
    end
    
    @infos = Array.new
    
    if @base_transit_form.day? # 日別表示
      
      for date in @base_transit_form.start_date..@base_transit_form.end_date
        day_info = Hash.new
        day_info[:date] = date.strftime('%Y/%m/%d')
        day_info[:join] = BaseUser.count_joined_at_by_period(date, date.next)
        day_info[:quit] = BaseUser.count_quitted_at_by_period(date, date.next)
        day_info[:all] = BaseUser.count_active_at_by_date(date)
        @infos << day_info
      end
    
    elsif @base_transit_form.month? # 月別表示
      
      date = @base_transit_form.start_date
      while date <= @base_transit_form.end_date
        next_month = date >> 1 # 次の月
        day_info = Hash.new
        day_info[:date] = date.strftime('%Y/%m')
        day_info[:join] = BaseUser.count_joined_at_by_period(date, next_month)
        day_info[:quit] = BaseUser.count_quitted_at_by_period(date, next_month)
        day_info[:all] = BaseUser.count_active_at_by_date(next_month - 1)
        @infos << day_info
        
        date = next_month
      end
    end
    
    if @base_transit_form.csv? # csv 出力の場合
      output_csv(@base_transit_form, @infos)
      
    else 
      start_date = @base_transit_form.start_date.strftime('%Y/%m/%d')
      end_date = @base_transit_form.end_date.strftime('%Y/%m/%d')
      
      @transit_graph = open_flash_chart_object(550,300, "/manage/base_transit/transit_graph?start_date=#{start_date}&end_date=#{end_date}&type=#{params[:type]}", true, '/')
      @all_transit_graph = open_flash_chart_object(550,300, "/manage/base_transit/all_transit_graph?start_date=#{start_date}&end_date=#{end_date}&type=#{params[:type]}", true, '/')
    end
  end
  
  def transit_graph
    data_1 = LineHollow.new(2,5,'#CC3399')
    data_1.key("入会者数",10)

    data_2 = LineHollow.new(2,4,'#80a033')
    data_2.key("退会者数", 10)

    dates = (Date.strptime(params[:start_date], "%Y/%m/%d")..Date.strptime(params[:end_date], "%Y/%m/%d")).map(&:to_s)
    
    max_count = 0
    case params[:type]
    when "day"  
      dates.each do |i|  
        join_count = BaseUser.count_joined_at_by_period(i, i.next)
        quit_count = BaseUser.count_quitted_at_by_period(i, i.next)
      
        data_1.add_data_tip(join_count,  "#{i}")
        data_2.add_data_tip(quit_count,  "#{i}")
      
        max_count = join_count if max_count < join_count
      end
        
    when "month"
      date = Date.strptime(params[:start_date], "%Y/%m/%d")
      dates = Array.new
      while date <= Date.strptime(params[:end_date], "%Y/%m/%d")
        dates << date
        next_month = date >> 1 # 次の月
        
        join_count = BaseUser.count_joined_at_by_period(date, next_month)
        quit_count = BaseUser.count_quitted_at_by_period(date, next_month)
        
        data_1.add_data_tip(join_count,  date.strftime("%Y/%m"))
        data_2.add_data_tip(quit_count,  date.strftime("%Y/%m"))
      
        date = next_month
        max_count = join_count if max_count < join_count
      end
    end

    g = Graph.new
    g.title("入退会者数遷移", "{font-size: 20px; color: #736AFF}")
    g.data_sets << data_1
    g.data_sets << data_2

    g.set_tool_tip('#x_label# [#val#]')
    g.set_x_labels(dates)
    g.set_x_label_style(10, '#000000', 0, 2)

    g.set_y_max(max_count)
    g.set_y_label_steps(4)

    render :text => g.render
  end
  
  def all_transit_graph
    data_1 = Line.new(2, '#9933CC')
    data_1.key('ユーザ数', 10)

    dates = (Date.strptime(params[:start_date], "%Y/%m/%d")..Date.strptime(params[:end_date], "%Y/%m/%d")).map(&:to_s)
    
    max_count = 0
    case params[:type]
      when "day"
        dates.each do |i|
          date = Date.strptime(i, "%Y-%m-%d")
          all_count = BaseUser.count_active_at_by_date(date)
          
          data_1.add_data_tip(all_count,  "#{i}")

          max_count = all_count if max_count < all_count
        end    
      when "month"
        dates = Array.new
        date = Date.strptime(params[:start_date], "%Y/%m/%d")
        while date <= Date.strptime(params[:end_date], "%Y/%m/%d")
          dates << date
          next_month = date >> 1 # 次の月
          
          all_count = BaseUser.count_active_at_by_date(next_month - 1)
          
          data_1.add_data_tip(all_count,  date.strftime("%Y/%m"))
          
          date = next_month
          max_count = all_count if max_count < all_count
        end
    end

    g = Graph.new
    g.title("ユーザ数遷移", "{font-size: 20px; color: #736AFF}")
    g.data_sets << data_1

    g.set_tool_tip('#x_label# [#val#]')
    g.set_x_labels(dates)
    g.set_x_label_style(10, '#000000', 0, 2)

    g.set_y_max(max_count)
    g.set_y_label_steps(4)

    render :text => g.render
  end
  
private 
  
  def output_csv(base_transit_form, infos)
    path = RAILS_ROOT + "/" + AppResources['base']['user_transit_file_path'] + "/"
    Dir::mkdir(path) unless File.exist?(path)
    
    file_name = Time.now.strftime("%Y%m%d%H%M%S") + Util.random_string(10)
    full_file_name = path + file_name
    
    FasterCSV.open(full_file_name, "w") do |csv|
      csv << [toUTF8("日付"), toUTF8("総ユーザ数"), toUTF8("入会者数"), toUTF8("入会者数")] # FIXME かなり無理矢理
      unless infos.empty?
        infos.each do |info|
          csv << ["#{info[:date]}","#{info[:all]}", "#{info[:join]}", "#{info[:quit]}"]
        end
      end
    end
    
    if base_transit_form.day?
      send_file full_file_name, :type => "text/csv;charset=UTF-8", :filename => "#{base_transit_form.start_date.strftime('%Y%m%d')}-#{base_transit_form.end_date.strftime('%Y%m%d')}.csv"
    else
      send_file full_file_name, :type => "text/csv;charset=UTF-8", :filename => "#{base_transit_form.start_date.strftime('%Y%m')}-#{base_transit_form.end_date.strftime('%Y%m')}.csv"
    end
  end
  
  def toUTF8(value)
    NKF.nkf('-m0 -x -Ws', value)
  end
end
