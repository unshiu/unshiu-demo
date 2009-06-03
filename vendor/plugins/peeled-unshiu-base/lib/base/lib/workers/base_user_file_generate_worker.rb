#
# ユーザ一覧ファイル生成
#  指定検索条件の一覧ファイルを生成する
#  10万ユーザ登録などの場合でも問題ないようにbackgroundで処理する
#　　フォーマットの変更をしたい場合は、適時　csv_headerやrecordメソッドをoverwriteする
#

module BaseUserFileGenerateWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :base_user_file_generate_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  # 日付をフォーマットして返す
  # _param1_:: datetime
  # return:: フォマットされた日付
  def datetime_str_format(datetime)
    if datetime
      datetime.strftime("%Y/%m/%d %H:%M:%S")
    else
      nil
    end
  end
  
  # ヘッダーレコード定義
  # return:: ヘッダーレコードのカラム配列
  def header
    [I18n.t('activerecord.attributes.base_user.uid'), I18n.t('activerecord.attributes.base_user.email'), I18n.t('activerecord.attributes.base_user.name'), I18n.t('activerecord.attributes.base_user.joined_at'), 
     I18n.t('activerecord.attributes.base_user.quitted_at'), I18n.t('activerecord.attributes.base_profile.birthday'), I18n.t('activerecord.attributes.base_profile.civil_status'), I18n.t('activerecord.attributes.base_profile.area'), 
     I18n.t('activerecord.attributes.base_user.receive_mail_magazine_flag'), I18n.t('activerecord.attributes.base_profile.sex')]
  end
  
  # 出力レコード定義
  # return:: 出力レコードのカラム配列
  def record(user)
    [user.id, user.email, user.name, datetime_str_format(user.joined_at), 
     datetime_str_format(user.quitted_at), '', '', '', user.receive_mail_magazine_flag, '']
  end
  
  # プロフィール情報があった場合の出力レコード定義
  # return:: 出力レコードのカラム配列
  def record_with_profile(user)
    [user.id, user.email, user.name, datetime_str_format(user.joined_at), 
     datetime_str_format(user.quitted_at), user.base_profile.birthday, BaseProfile.civil_status_kind_name(user.base_profile.civil_status), 
     BaseProfile.area_kind_name(user.base_profile.area), user.receive_mail_magazine_flag, BaseProfile.sex_kind_name(user.base_profile.sex)]
  end
  
  # 実行処理
  def generate(rp = {})
    @logger.info "base user file generate start : #{Time.now}"
    
    first = BaseUser.minimum(:id)
    last = BaseUser.maximum(:id)
    limit = AppResources[:base][:user_csv_one_time_size]
    from = first
    to = first
    
    buf = FasterCSV.generate do |csv|
      csv << header
      
      loop do
        to += limit - 1
        users = BaseUser.find_users_by_all_search_info(rp[:user_info], rp[:profile_info], rp[:point_info],
                                                       {:conditions => "base_users.id between #{from} and #{to}"})
        users.each do | user |
          csv_record = user.base_profile.nil? ? record(user) : record_with_profile(user)
          csv << csv_record
        end
        break if to >= last
        from = to + 1
      end
    end
    
    base_user_file_hitory = BaseUserFileHistory.find(rp[:base_user_file_history_id])
    
    dir_path = "#{RAILS_ROOT}/#{AppResources[:base][:user_csv_file_path]}/"
    Dir::mkdir(dir_path) unless File.exist?(dir_path)
    output_file_path_name = dir_path + base_user_file_hitory.file_name
    
    # FIXME これだと大量データすべてbufにもち、書き出ししているので対象を広範囲にされるとメモリ食い尽くさない？
    file = File.open(output_file_path_name, "w")
    file.puts NKF.nkf('-m0 -x -Ws', buf)
    file.close
    File::chmod(0100666, output_file_path_name)
  
    base_user_file_hitory.complated_at = Time.now # 完了日付を更新
    base_user_file_hitory.save
      
  rescue Exception => e
    @logger.error "base user file generate \n #{e}"
  end
  
end
