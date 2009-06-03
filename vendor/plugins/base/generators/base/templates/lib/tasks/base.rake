namespace :unshiu do
  
  namespace :base do
    
    namespace :sample do
      
      desc 'create base latest test data generate.'
      task :create_latest_login, "max_size"
      task :create_latest_login => [:environment] do |task, args|
        task.set_arg_names ["max_size"]
        for i in 1..args.max_size.to_i
          latestd_at = Time.now - rand(60*60*24*30*6)

          mixi_latest_login = BaseLatestLogin.new
          mixi_latest_login.base_user_id = i
          mixi_latest_login.latest_login = latestd_at
          mixi_latest_login.save
        end
      end
    
      desc 'create base latest active_history test data generate.'
      task :create_active_history, "before_days"
      task :create_active_history => [:environment] do |task, args|
        task.set_arg_names ["before_days"]
        start = Date.today - 1.years
        for date in start..Date.today
          BaseActiveHistory.create(:before_days => args.before_days, :history_day => date, :user_count => rand(100000))
        end
      end
      
    end
  
    namespace :emoticons do
      desc 'genarate html for emoticons '
      task :generate_html do
        EMOTICONS = YAML::load(IO.read("#{RAILS_ROOT}/config/emoticon.yaml"))
        range = 12
        
        file = open("#{RAILS_ROOT}/app/views/common/_emoticons_pad.html.erb", "w")
        file.puts "<tr>"
        EMOTICONS['docomo'].keys.sort.each_with_index do |code, index|
          file.puts "<td id='em_#{code}'><img src='/images/emoticons/#{EMOTICONS['docomo'][code]}.gif'></td>"
          file.puts "</tr><tr>\n"  if (index+1) % range == 0
        end
        
        if EMOTICONS['docomo'].keys.sort.size % range != 0
          n = EMOTICONS['docomo'].keys.sort.size
          while  (n % range != 0)
            n += 1
            puts "<td class='null_emoji'>&nbsp;</td>"
          end
        end
      end
    end
  end
end
