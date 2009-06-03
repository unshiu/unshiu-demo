#
# 管理者ログ生成処理
#
module MngUserActionHistoryArchiveCreateWorkerModule
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :mng_user_action_history_archive_create_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  # ヘッダーレコード定義
  # return:: ヘッダーレコードのカラム配列
  def header
    ["ユーザID", "処理", "日"]
  end
  
  def generate_file
    start_date = Date.today - 1.days
    start_datetime = Time.mktime(start_date.year, start_date.month, start_date.day, 23,59,59)
    end_datetime = Date.today - 7.days
     
    mng_user_action_hitory_archive = MngUserActionHistoryArchive.new
    mng_user_action_hitory_archive.filename = Util.random_string(32) + ".csv"
    mng_user_action_hitory_archive.start_datetime = start_datetime
    mng_user_action_hitory_archive.end_datetime = end_datetime

    dir_path = "#{RAILS_ROOT}/#{AppResources[:mng][:mng_user_action_hitory_archive_file_path]}/"
    Dir::mkdir(dir_path) unless File.exist?(dir_path)
    output_file_path_name = dir_path + mng_user_action_hitory_archive.filename
    
    FasterCSV.open(output_file_path_name, "w") do |csv|
      csv << header
      
      histories = MngUserActionHistory.find(:all, :conditions => ['created_at between ? and ? ', end_datetime, start_datetime])
      histories.each do | history |
        csv << [history.base_user.login, history.user_action, history.created_at]
        history.destroy
      end
    end
    
    mng_user_action_hitory_archive.filesize = File.size(output_file_path_name)
    mng_user_action_hitory_archive.save!
  
  rescue Exception => e
    @logger.error "mng user action hitory archive file generate \n #{e}"
  end

end
