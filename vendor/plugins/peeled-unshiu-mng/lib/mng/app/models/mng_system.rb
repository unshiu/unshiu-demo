module MngSystemModule
  
  class << self
    def included(base)
      base.class_eval do
        const_set('ADMIN_BASE_USER_ID', 1)
        const_set('ADMIN_DEFAULT_PASSWORD', 'test')
      end
    end
  end
  
  # 本番環境かどうかをかえす
  # return:: production環境ならtrue,そうでなければfalse
  def production?
    RAILS_ENV == 'production'
  end
  
  # 管理者がデフォルトログインパスワード設定かどうかを返す
  # return:: デフォルトログインパスワードならtrue,そうでなければfalse
  def login_passowrd_security?
    base_user = BaseUser.find(MngSystem::ADMIN_BASE_USER_ID)
    !base_user.authenticated?(MngSystem::ADMIN_DEFAULT_PASSWORD)
  end
  
  # ポータルのアルバムキャッシュ時間を返す
  # return:: ポータルのアルバムキャッシュ時間(sec)
  def album_portal_cache_time
    AppResources[:abm][:abm_album_cache_time]
  end
  
  # ポータルのコミュニティキャッシュ時間を返す
  # return:: ポータルのコミュニティキャッシュ時間(sec)
  def community_portal_cache_time
    AppResources[:cmm][:cmm_community_cache_time]
  end
  
  # ポータルの日記キャッシュ時間を返す
  # return:: ポータルの日記キャッシュ時間(sec)
  def diary_portal_cache_time
    AppResources[:dia][:dia_diary_cache_time]
  end
  
  # ポータルのトピックキャッシュ時間を返す
  # return:: ポータルのトピックキャッシュ時間(sec)
  def topic_portal_cache_time
    AppResources[:tpc][:tpc_topic_cmm_community_cache_time]
  end
  
  # apacheのアクセスログが出力されているか
  # return:: apacheのアクセスログが出力されていればtrue,そうでなければfalse
  def output_apache_access_log?
    Dir::glob("#{AppResources[:mng][:apache_log_dir]}/*").each do |f|
      return true if File::basename(f) == AppResources[:mng][:apache_access_log_filename]
    end
    return false
  end
  
  # apacheのアクセスログはローテートされているか
  # return:: apacheのアクセスログはローテートされていればtrue,そうでなければfalse
  def output_apache_access_log_with_logrotate?
    Dir::glob("#{AppResources[:mng][:apache_log_dir]}/*").each do |f|
      return true if File::basename(f) =~ /#{AppResources[:mng][:apache_access_log_filename]}\.\d+/
    end
    return false
  end
  
  # railsのログは出力されているか
  # return:: railsのログは出力されていればtrue,そうでなければfalse
  def output_rails_log?
    Dir::glob("#{RAILS_ROOT}/log/*").each do |f|
      return true if File::basename(f) == "#{RAILS_ENV}.log"
    end
    return false
  end
  
  # MySQLのスロークエリログが出力設定がされているか
  # return:: MySQLのスロークエリログが出力設定がされていればtrue,そうでなければfalse
  def mysql_slow_query_log?
    result = false
    open(AppResources[:mng][:mysql_conf_file]) do |file|
      while line = file.gets
        result_file = true if line =~ /^log-slow-queries/
        result_time = true if line =~ /^long_query_time/
        result_index = true if line =~ /^log-queries-not-using-indexes/
        result = true if result_file && result_time && result_index
      end
    end
    result
  end
  
  # MySQLのスロークエリログ出力ディレクトリを返す
  # return:: MySQLのスロークエリログ出力ディレクトリ
  def mysql_slow_query_log_file
    result = nil
    open(AppResources[:mng][:mysql_conf_file]) do |file|
      while line = file.gets
        if line =~ /^log-slow-queries/
          params = line.chomp.split('=')
          result = params[1].strip if params.size == 2
        end
      end
    end
    result
  end
  
  # MySQLのスロークエリと判断される秒数を返す。この設定値秒以上かかったクエリはスロークエリと判断されログに出力される。
  # return:: MySQLスロークエリ規程秒設定値
  def mysql_slow_query_long_query_time
    result = nil
    open(AppResources[:mng][:mysql_conf_file]) do |file|
      while line = file.gets
        if line =~ /^long_query_time/
          params = line.chomp.split('=')
          result = params[1].to_i if params.size == 2
        end
      end
    end
    result
  end
  
  # インデックスを利用しなかったクエリをスロークエリと判断しログに出力するか
  # return:: インデックスを利用しなかったクエリをスロークエリと判断しログに出力する場合true,そうでなければfalse
  def mysql_slow_query_not_using_indexes?
    result = false
    open(AppResources[:mng][:mysql_conf_file]) do |file|
      while line = file.gets
        result = true if line =~ /^log-queries-not-using-indexes/
      end
    end
    result
  end
  
  # ファイル書き込み領域に書き込み権限はあるか
  # return:: ファイル書き込み領域に権限があればtrue,そうでなければfalse
  def file_writable?
    File.writable?("#{RAILS_ROOT}/#{AppResources[:init][:file_column_image_root_path]}")
  end
  
  # dfのコマンド結果を出力
  # return:: dfコマンド出力結果
  def df
    %x{ "df" }
  end
  
  # backgroundrb情報を出力
  # return:: backgroundrb情報出力結果
  def backgrourndrb_worker_info
    MiddleMan.all_worker_info
  end
  
  # apacheのvhostsの設定ファイル情報を出力
  # return:: apacheのvhostsの設定内容出力
  def httpd_vhosts_conf
    open(httpd_vhosts_conf_path).read if File.exist?(httpd_vhosts_conf_path)
  end

  # 各サーバのchkconfig結果ファイルハッシュを返す。
  # return:: key->host名, value->ファイル内容
  def chkconfigs
    result = {}
    Dir::glob(chkconfig_pattern).each do |file|
      filename = File::basename(file).gsub(/chkconfig-/, '')
      result[filename] = open(file).read
    end
    return result
  end
  
  # 各サーバのcron結果ファイルハッシュを返す。
  # return:: key->host名, value->ファイル内容
  def crons
    result = {}
    Dir::glob(cron_pattern).each do |file|
      filename = File::basename(file).gsub(/cron-/, '')
      result[filename] = open(file).read
    end
    return result
  end
  
  # DNS情報を出力
  # return:: 自ドメインのdigの結果
  def dig
    %x{ "dig #{AppResources[:init][:application_domain]}" }
  end
  
  # DNS　MXレコード情報を出力
  # return:: 自ドメインのdig　mxの結果
  def dig_mx
    %x{ "dig #{ActionMailer::Base.smtp_settings[:domain]}" mx }
  end
  
private

  # apacheのvhostsファイルの場所を返す。テスト用のstubを考慮し切り出している。
  def httpd_vhosts_conf_path
   "#{AppResources[:mng][:apache_home]}/extra/httpd-vhosts.conf"
  end
  
  # chkconfig出力結果。テスト用のstubを考慮し切り出している。
  def chkconfig_pattern
    "#{AppResources[:init][:chkconfig_outputfile_path]}/chkconfig*"
  end

  # cron出力結果。テスト用のstubを考慮し切り出している。
  def cron_pattern
    "#{AppResources[:init][:crontab_outputfile_path]}/cron*"
  end
  
end