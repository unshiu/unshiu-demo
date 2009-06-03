require 'rubygems'
require 'fastercsv'
require 'logger'
require 'mysql'
require 'cgi'

# = AceLogSystemModule
#
# == Summary
# ログ解析処理全般を行う
module AceLogSystemModule
  
  class Logger
    
    def initialize
      @@log = ::Logger.new("#{ENV["RAILS_ROOT"]}log/carbon_#{ENV["RAILS_ENV"]}.log")
      @@log.level = ::Logger::DEBUG
      @@log.info("[start] carbon : #{Time.now}")
    end
    
    # ロギング処理はすべてこのメソッドを通じて行う
    # Examples ) 
    #  Carbon::Logger.log.error("error message")
    def self.log
      @@log
    end
  end
  
  module Parser
    
    class Base
      attr_reader :logs
      
      def initialize
        @logs = Dir::glob(AppResources[:ace][:target_pattern])
      end
    
      # fastercsvの初期化
      # 利用するcsvの基本構造などはすべて同一のためフォーマットの調整などはこのメソッドで行う
      def self.fastercsv(file)
        FasterCSV.open(file,:col_sep=>"\t")
      end
    end
    
    class AccessLog < AceLogSystemModule::Parser::Base
      
      RECORD_COLUMN_SIZE = 9 # 1行としてみなされるレコードのカラム数
    
      # アクセスログレコードを解析してHashにしてかえす
      # アクセスログとして仕様をみたさない文字列を渡されたらnilを返す
      # _param1_:: 1レコード文字列
      # return:: ログのHasu
      def self.parse_log_record(record)
        return nil if record.size != RECORD_COLUMN_SIZE
        time_parts = record[1].delete("[]").split(/[\/ :.]/)
        new_times = [time_parts[2],time_parts[1],time_parts[0],time_parts[3],time_parts[4],time_parts[5]]
        new_time = Time.utc(*new_times)
      
        { :host => record[0], :access_at => new_time, :response_code => record[3],
          :user_agent => record[5], :base_user_id => record[6], :request_url => CGI::unescape(record[7]) }
      end
    end
    
    class Footmark < AceLogSystemModule::Parser::Base
      
      RECORD_COLUMN_SIZE = 2 # 1行としてみなされるレコードのカラム数
      
      RECORD_COLUMN_NUM_ACCESS_AT = 0 # アクセス時刻のカラム番号
      RECORD_COLUMN_NUM_UUID      = 1 # UUIDのカラム番号
      
      # 足跡ログレコードを解析してHashにしてかえす
      # 足跡ログとして仕様をみたさない文字列を渡されたらnilを返す
      # _param1_:: 1レコード文字列
      # return:: ログのHasu
      def self.parse_log_record(record)
        return nil if record.size != RECORD_COLUMN_SIZE
        time_parts = record[RECORD_COLUMN_NUM_ACCESS_AT].delete("[]").split(/[\/ :.]/)
        new_times = [time_parts[2],time_parts[1],time_parts[0],time_parts[3],time_parts[4],time_parts[5]]
        new_time = Time.utc(*new_times)
      
        { :access_at => new_time, :uuid => record[RECORD_COLUMN_NUM_UUID] }
      end
    end
    
  end
  
  module Database
    
    class Base
      attr_reader :db, :ace_access_log, :ace_parse_log, :ace_footmark
      attr_reader :file, :filename
      
      def initialize
        @db = Mysql::connect(AppResources[:ace][:host], AppResources[:ace][:username], 
                             AppResources[:ace][:password], AppResources[:ace][:database])
        @db.autocommit(false)
        @ace_access_log = AceAccessLog.new(@db)
        @ace_parse_log = AceParseLog.new(@db)
        @ace_footmark = AceFootmark.new(@db)
      end
      
      # アクセスログレコードの永続化処理
      # _param1_:: 対象ファイル
      def access_log_process(file)
        AceLogSystemModule::Logger.log.info("target:#{file}")
        
        @file = file
        
        csv = seeked_csvfile
        return if csv.eof?
        
        tell = 0
        csv.each_with_index do |record, index|
          record = AceLogSystemModule::Parser::AccessLog.parse_log_record(record)
          break if record.nil?
        
          @ace_access_log.add(record)
          tell = csv.tell
          if index != 0 && index % AppResources[:ace][:commit_unit] == 0
            @ace_parse_log.insert_or_update_log(AppResources[:ace][:client_id], filename, tell)
            @db.commit
          end  
        end
      
      rescue => e
        AceLogSystemModule::Logger.log.error("#{filename}:#{tell} #{e}")
      ensure
        @ace_parse_log.insert_or_update_log(AppResources[:ace][:client_id], filename, tell)
        @db.commit
      end
      
      # 足跡ログレコードの永続化処理
      # _param1_:: 対象ファイル
      def footmark_process(file)
        @file = file
        
        csv = seeked_csvfile
        return if csv.eof?
        
        tell = 0
        update_records = Hash.new
          
        csv.each_with_index do |record, index|
          record = AceLogSystemModule::Parser::Footmark.parse_log_record(record)
          break if record.nil?
          
          target = update_records[record[:uuid]]
          if target.nil?
            update_records[record[:uuid]] = { :access_at => record[:access_at], :count => 1 }
          else
            target[:count] = target[:count] + 1
            target[:access_at] = record[:access_at] if target[:access_at].to_i < record[:access_at].to_i
          end
          tell = csv.tell
          if index != 0 && index % AppResources[:ace][:commit_unit] == 0
            update_footmark(update_records, tell)
            update_records = Hash.new
          end
        end
          
      rescue => e
        AceLogSystemModule::Logger.log.error("#{filename}:#{tell} #{e}")
      ensure        
        update_footmark(update_records, tell)
      end
      
      def commit
        @db.commit
      end
      
      def close
        @ace_access_log.close if @ace_access_log
        @ace_parse_log.close if @ace_parse_log
        @db.close if @db
      end
      
    private
      
      def filename
        @filename ||= File.basename(@file)
      end
      
      def seeked_csvfile
        log = @ace_parse_log.find_log(AppResources[:ace][:client_id], filename)
        csv = AceLogSystemModule::Parser::Base.fastercsv(@file)
        csv.seek(log[AceParseLog::FIND_LOG_COUMN_COMPLATE_POINT]) unless log.nil?
        return csv
      end
      
      def update_footmark(records, tell)
        records.each_pair do |uuid, value|
          @ace_footmark.update({:uuid => uuid, :access_at => value[:access_at], :count => value[:count]})
        end
        @ace_parse_log.insert_or_update_log(AppResources[:ace][:client_id], filename, tell)
        @db.commit
      end
    end  
  
    class AceAccessLog
      attr_reader :insert_stmt
      
      def initialize(db)
      
        psql = "INSERT INTO ace_access_logs (host, response_code, user_agent, base_user_id, access_at) " + 
               "VALUES ( ?, ?, ?, ?, ? )"
        @insert_stmt = db.prepare(psql)
      end
      
      # アクセスログレコードの追加
      # _param1_:: record
      def add(record)
        @insert_stmt.execute(record[:host], record[:response_code], record[:user_agent], record[:base_user_id].to_i, record[:access_at])
      end
      
      def close
        @insert_stmt.close
      end
    end
    
    class AceFootmark
      attr_reader :update_stmt, :updated_update_stmt
      
      def initialize(db)
        psql = "UPDATE ace_footmarks SET count = count + ? where uuid = ? "
        @update_stmt = db.prepare(psql)
        psql = "UPDATE ace_footmarks SET updated_at = ? where uuid = ? and updated_at < ?"
        @updated_update_stmt = db.prepare(psql)
      end
      
      # 足跡の更新
      # _param1_:: record
      def update(record)
        # 足跡更新日が最新であるかselectで最新のものを取得して確認する必要があるが取得→更新をするくらいなら条件式で更新をかける
        @update_stmt.execute(record[:count], record[:uuid])
        @updated_update_stmt.execute(record[:access_at], record[:uuid], record[:access_at])
      end
      
      def close
        @update_stmt.close
        @updated_update_stmt.close
      end
    end
    
    class AceParseLog
      attr_reader :find_log_stmt, :update_log_stmt, :insert_log_stmt
      
      FIND_LOG_COUMN_COMPLATE_POINT = 3 
      
      def initialize(db)
        psql = "select * from ace_parse_logs where client_id = ? and filename = ? and deleted_at is null "
        @find_log_stmt = db.prepare(psql)

        psql = "update ace_parse_logs set complate_point = ? where client_id = ? and filename = ?"
        @update_log_stmt = db.prepare(psql)
        
        psql = "insert into ace_parse_logs (client_id, filename, complate_point ) VALUES ( ?, ?, ? )"
        @insert_log_stmt = db.prepare(psql)
      end
      
      # 対象解析ログの検索
      # _param1_:: client_id
      # _param2_:: filename
      def find_log(client_id, filename)
        @find_log_stmt.execute(client_id, filename)
        @find_log_stmt.fetch
      end
      
      # 対象解析ログの更新。対象がなければ追加する
      # _param1_:: client_id
      # _param2_:: filename
      # _param3_:: complate_point 解析完了ポイント
      def insert_or_update_log(client_id, filename, complate_point)
        log = find_log(client_id, filename)
        if log == nil || log.size == 0
          @insert_log_stmt.execute(client_id, filename, complate_point)
        else
          @update_log_stmt.execute(complate_point, client_id, filename)
        end
      end
      
      def close
        @find_log_stmt.close if @find_log_stmt
        @update_log_stmt.close if @update_log_stmt
        @insert_log_stmt.close if @insert_log_stmt
      end
      
    end
  end
end