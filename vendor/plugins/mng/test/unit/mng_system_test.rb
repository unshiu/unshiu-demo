require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

module MngSystemTestModule

  define_method('test: 管理者のパスワードがデフォルトの場合はセキュリティは false') do 
    system = MngSystem.new
    assert_equal(system.login_passowrd_security?, false)
  end
  
  define_method('test: 管理者のパスワードがデフォルトのもの以外に設定されていた場合はセキュリティは true') do
    base_user = BaseUser.find(1)
    base_user.password = 'securitetrue'
    base_user.save!
    
    system = MngSystem.new
    assert_equal(system.login_passowrd_security?, true)
  end
  
  define_method('test: アルバム一覧のポータルのキャッシュ時間を返す') do 
    system = MngSystem.new
    assert_equal(system.album_portal_cache_time, 600)
  end
  
  define_method('test: コミュニティ一覧のポータルのキャッシュ時間を返す') do 
    system = MngSystem.new
    assert_equal(system.community_portal_cache_time, 600)
  end
  
  define_method('test: 日記一覧のポータルのキャッシュ時間を返す') do 
    system = MngSystem.new
    assert_equal(system.diary_portal_cache_time, 600)
  end
  
  define_method('test: トピック一覧のポータルのキャッシュ時間を返す') do 
    system = MngSystem.new
    assert_equal(system.topic_portal_cache_time, 600)
  end
  
  define_method('test: Apacheのアクセスログが正常に出力されているか判別する') do 
    system = MngSystem.new
    assert_equal(system.output_apache_access_log?, true)
  end
  
  define_method('test: Apacheのアクセスログが正常に出力されており、かつローテートされているか判別する') do 
    system = MngSystem.new
    assert_equal(system.output_apache_access_log_with_logrotate?, true)
  end
  
  define_method('test: railsのログが出力されているか判別する') do 
    system = MngSystem.new
    assert_equal(system.output_rails_log?, true)
  end
  
  define_method('test: railsの実行環境はproductionか判別する') do 
    system = MngSystem.new
    assert_equal(system.production?, false) # テストの際は当然out
  end
  
  define_method('test: mysqlのquerylogの設定はしてあるか判別できる') do 
    system = MngSystem.new
    assert_equal(system.mysql_slow_query_log?, true) 
  end
  
  define_method('test: 必要な設定が全部そろっていなければmysqlのquerylogの設定はしていないとみなされる') do 
    system = MngSystem.new
    backup = AppResources[:mng][:mysql_conf_file]
    
    # ログの設定がすべてそろってないファイル
    AppResources[:mng][:mysql_conf_file] = "test/file/mng_system_my_cnf_err_sample.txt"
    assert_equal(system.mysql_slow_query_log?, false)
     
    AppResources[:mng][:mysql_conf_file] = backup # 事後処理：設定値を元に戻す
  end
  
  define_method('test: mysqlのquerylog出力場所を取得する') do 
    system = MngSystem.new
    assert_equal(system.mysql_slow_query_log_file, "/var/log/mysql/mysql-slow.log")
  end
  
  define_method('test: mysqlのquerylogで何秒以上処理に時間がかかったら取得するかの値を取得する') do 
    system = MngSystem.new
    assert_equal(system.mysql_slow_query_long_query_time, 5) # 5秒以上かかったらログに記録する
  end
  
  define_method('test: mysqlのquerylogのインデックス設定値を取得する') do 
    system = MngSystem.new
    assert_equal(system.mysql_slow_query_not_using_indexes?, true) # indexを使っていないクエリはログ出力対象とする
  end
  
  define_method('test: 各種ファイル出力ディレクトリに書き込み権限はあるか') do 
    system = MngSystem.new
    assert_equal(system.file_writable?, true) 
  end
  
  define_method('test: ディスク容量を取得する') do 
    system = MngSystem.new
    assert_not_nil(system.df) 
  end
  
  define_method('test: backgroundrbの情報を出力する') do 
    system = MngSystem.new
    assert_not_nil(system.backgrourndrb_worker_info)
  end
  
  define_method('test: apacheの設定情報を出力する') do
    
    system = MngSystem.new
    system.stubs(:httpd_vhosts_conf_path).returns("test/file/mng_system_httpd_vhosts_conf.txt")
    
    assert_not_nil(system.httpd_vhosts_conf)
  end
  
  define_method('test: 各サーバで自動起動設定がどうなっているか出力する') do
    system = MngSystem.new
    system.stubs(:chkconfig_pattern).returns("test/file/mng_chkconfg-test.example.com.txt")
    
    assert_not_nil(system.chkconfigs)
    assert_not_equal(system.chkconfigs.size, 0)
    
    system.chkconfigs.each do |chkconfig|
      assert_not_nil(chkconfig)
    end
  end
  
  define_method('test: 各サーバでcron設定がどうなっているか出力する') do
    system = MngSystem.new
    system.stubs(:cron_pattern).returns("test/file/mng_cron-test.example.com.txt")
    
    assert_not_nil(system.crons)
    assert_not_equal(system.crons.size, 0)
    
    system.crons.each do |cron|
      assert_not_nil(cron)
    end
  end
  
  define_method('test: DNS情報を出力する') do
    system = MngSystem.new
    assert_not_nil(system.dig)
  end

  define_method('test: DNS MX情報を出力する') do
    system = MngSystem.new
    assert_not_nil(system.dig_mx)
  end
  
end