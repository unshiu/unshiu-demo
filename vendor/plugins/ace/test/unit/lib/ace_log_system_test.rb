require File.dirname(__FILE__) + '/../../test_helper'
require 'pp'

module AceLogSystemTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        self.use_transactional_fixtures = false
        fixtures :ace_parse_logs
        fixtures :ace_footmarks
        fixtures :ace_access_logs
      end
    end
  end
  
  define_method('test: アクセスログが1行が解析されて、データベースに挿入可能な値のHashになる') do 
    @valid_attributes = {
      :record => ["127.0.0.1", "[13/Nov/2008:14:50:35 +0900]", "\"GET /img/base_user_id_1/url_%2F%26aaaa/access.gif?timestamp=1226386325 HTTP/1.1\"", "200", "242", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3", "1", "%2F%26aaaa", "u"],
      :short_error_record => ["127.0.0.1", "[13/Nov/2008:14:50:35 +0900]", "\"GET /img/base_user_id_1/url_%2F%26aaaa/access.gif?timestamp=1226386325 HTTP/1.1\"", "200", "242", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3", "1"],
    }
    
    record = AceLogSystemModule::Parser::AccessLog.parse_log_record(@valid_attributes[:record])
    assert_equal(record.size, 6)
    assert_equal(record[:host], "127.0.0.1")
    assert_equal(record[:access_at].to_s, "Thu Nov 13 14:50:35 UTC 2008")
    assert_equal(record[:access_at].class, Time.new.class)
    assert_equal(record[:response_code], "200")
    assert_equal(record[:user_agent], "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3")
    assert_equal(record[:request_url], "/&aaaa")
    assert_equal(record[:base_user_id], "1")
  end
  
  define_method('test: アクセスログでまだ出力が完了していないレコードの場合はめnilがかえる') do 
    @valid_attributes = {
      :record => ["127.0.0.1", "[13/Nov/2008:14:50:35 +0900]", "\"GET /img/base_user_id_1/url_%2F%26aaaa/access.gif?timestamp=1226386325 HTTP/1.1\"", "200", "242", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3", "1", "%2F%26aaaa", "u"],
      :short_error_record => ["127.0.0.1", "[13/Nov/2008:14:50:35 +0900]", "\"GET /img/base_user_id_1/url_%2F%26aaaa/access.gif?timestamp=1226386325 HTTP/1.1\"", "200", "242", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3", "1"],
    }
    
    record = AceLogSystemModule::Parser::AccessLog.parse_log_record(@valid_attributes[:short_error_record])
    assert_nil(record)
  end
  
  define_method('test: 足跡ログが1行が解析されて、データベースに挿入可能な値のHashになる') do 
    @valid_attributes = {
      :footmark_record => ["[13/Nov/2008:14:50:35 +0900]", "59204545-7344-4e2a-a5ae-849c4fb898c5"]
    }
    
    record = AceLogSystemModule::Parser::Footmark.parse_log_record(@valid_attributes[:footmark_record])
    assert_equal(record.size, 2)
    assert_equal(record[:access_at].to_s, "Thu Nov 13 14:50:35 UTC 2008")
    assert_equal(record[:uuid], "59204545-7344-4e2a-a5ae-849c4fb898c5")
  end
  
  define_method('test: レコードの永続化処理のために接続を初期化する') do
    @log = AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    assert_not_nil(@db)
  end
  
  define_method('test: 解析したレコードをace_access_logsに追加する') do 
    @valid_attributes = {
      :record => {:host => "127.0.0.1", :response_code => "200", :user_agent => "Firefox", :base_user_id => "1", :access_at => Time.now},
    }
    
    @log = AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    rs = @db.db.query("select * from ace_access_logs")
    before_row = rs.num_rows
    
    @db.ace_access_log.add(@valid_attributes[:record])
    @db.commit
    
    rs = @db.db.query("select * from ace_access_logs")
    after_row = rs.num_rows
    
    assert_equal(after_row, before_row + 1) # 1レコード追加されている
  end
  
  define_method('test: 解析処理ログを取得する') do 
    @log = AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    log = @db.ace_parse_log.find_log(1, "unshiu_imp.log.1111target")
    assert_not_nil(log)
    assert_equal(log[3].to_i, 0)
    
    log = @db.ace_parse_log.find_log(1, "unshiu_imp.log.1111delete")
    assert_nil(log)
        
    log = @db.ace_parse_log.find_log(999, "unshiu_imp.log.1111target")
    assert_nil(log)
  end
  
  define_method('test: 解析処理ログを更新する') do 
    @log = AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    @db.ace_parse_log.insert_or_update_log(1, "unshiu_imp.log.1111target", 200)
    @db.commit
    
    rs = @db.db.query("select * from ace_parse_logs where client_id = 1 and filename = 'unshiu_imp.log.1111target'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["complate_point"].to_i, 200) # 更新されている
    end
  end
  
  define_method('test: 解析処理ログを追加する') do 
    @log = AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    @db.ace_parse_log.insert_or_update_log(1, "unshiu_imp.log.1111add", 1000)
    @db.commit
    
    rs = @db.db.query("select * from ace_parse_logs where client_id = 1 and filename = 'unshiu_imp.log.1111add'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["complate_point"].to_i, 1000) # 追加されている
    end
  end
  
  define_method('test: ログファイルを解析して処理できる') do 
    @log = AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    target_file = self.fixture_path + 'file/sample_access.log.1111'
    
    @db.access_log_process(target_file)
    
    rs = @db.db.query("select * from ace_parse_logs where client_id = 1 and filename = 'sample_access.log.1111'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["complate_point"].to_i, 275646)
    end
    
    rs = @db.db.query("select * from ace_access_logs")
    assert_equal(rs.num_rows, 1000)
    
    @db.close
  end
  
  define_method('test: csvでの解析ができない状態のレコードの場合はその前まで処理をする') do 
    @log = AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    target_file = self.fixture_path + '../file/ace_imp.log.1111error.txt'
    rs = @db.db.query("select * from ace_access_logs")
    before_row = rs.num_rows
    
    @db.access_log_process(target_file)
    
    rs = @db.db.query("select * from ace_parse_logs where client_id = 1 and filename = 'ace_imp.log.1111error.txt'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["complate_point"].to_i, 1104)
    end
    
    rs = @db.db.query("select * from ace_access_logs")
    assert_equal(rs.num_rows, before_row + 4) # エラー行の前までは解析できている
    
    @db.close
  end
  
  define_method('test: 足跡ログは解析したレコード情報を ace_footmarks に追加し、最終アクセス日とカウントが更新される') do 
    @valid_attributes = {
      :exisitence_footmark_record => {:access_at => "2100/10/11 12:30:12", :uuid => "1111-1111-1111-1111", :count => 10 },
      :no_exisitence_footmark_record => {:access_at => "2008/10/11 12:30:12", :uuid => "59204545-7344-4e2a-a5ae-849c4fb898c5", :count => 1}
    }
    AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    rs = @db.db.query("select * from ace_footmarks where uuid = '1111-1111-1111-1111'")
    assert_equal(rs.num_rows, 1)
    
    before_access_at = nil
    before_record_count = 0
    rs.each_hash do |record|
      before_access_at = record["updated_at"]
      before_record_count = record["count"].to_i
    end
    
    @db.ace_footmark.update(@valid_attributes[:exisitence_footmark_record])
    @db.commit
    
    rs = @db.db.query("select * from ace_footmarks where uuid = '1111-1111-1111-1111'")
    assert_equal(rs.num_rows, 1)
    
    rs.each_hash do |record|
      assert_not_equal(record["updated_at"], before_access_at) # 更新されている
      assert_equal(record["count"].to_i, before_record_count + 10)  # 足跡を踏まれた数が :count 分アップしている
    end
  end
  
  define_method('test: 解析したレコードを ace_footmarks に追加するが、カウント対象がなないためレコード数は増えない') do 
    @valid_attributes = {
      :exisitence_footmark_record => {:access_at => "2100/10/11 12:30:12", :uuid => "1111-1111-1111-1111", :count => 10 },
      :no_exisitence_footmark_record => {:access_at => "2008/10/11 12:30:12", :uuid => "59204545-7344-4e2a-a5ae-849c4fb898c5", :count => 1}
    }
    AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    @db.ace_footmark.update(@valid_attributes[:no_exisitence_footmark_record])
    @db.commit
    
    rs = @db.db.query("select * from ace_footmarks where uuid = '59204545-7344-4e2a-a5ae-849c4fb898c5'")
    assert_equal(rs.num_rows, 0) # レコードはない
  end
  
  define_method('test: ログファイルを解析して処理できる') do 
    AceLogSystemModule::Logger.new
    @db = AceLogSystemModule::Database::Base.new
    
    target_file = self.fixture_path + '../file/ace_footmark.log.1111.txt'
    
    @db.footmark_process(target_file)
    
    rs = @db.db.query("select * from ace_parse_logs where client_id = 1 and filename = 'ace_footmark.log.1111.txt'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["complate_point"].to_i, 68000)
    end
    
    rs = @db.db.query("select * from ace_footmarks where uuid = '5b6fc66b-32fd-492e-92fb-f12ea08305ca'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["updated_at"], "2008-12-02 20:48:13") # 一番新しい更新日に更新されている
      assert_equal(record["count"].to_i, 11)
    end
    
    rs = @db.db.query("select * from ace_footmarks where uuid = '877b3496-99d1-4409-a607-b8a7bfb1e761'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["updated_at"], "2008-12-01 23:22:22") # 一番新しい更新日に更新されている
      assert_equal(record["count"].to_i, 16)
    end
    
    rs = @db.db.query("select * from ace_footmarks where uuid = 'c7b68f1a-a2c3-4f4d-ac31-2322920074c3'")
    assert_equal(rs.num_rows, 1)
    rs.each_hash do |record|
      assert_equal(record["updated_at"], "2100-01-01 00:00:00") # 更新日はDBのが一番最新なので更新されてない
      assert_equal(record["count"].to_i, 1014)
    end
    
    @db.close
  end
  
end