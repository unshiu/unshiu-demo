#
# アクティブユーザ数履歴計測処理
#
module BaseActiveHistoryCreateWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :base_active_history_create_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  # 前日までにログインした履歴のあるアクティブユーザ数計測をする
  def update_yesterday_active_count
    start_at = Time.now.yesterday.beginning_of_day
    end_at = Time.now.yesterday.end_of_day  
    update_active_count_by_day(1, start_at, end_at)
  end
  
  # 過去3日以内ログインした履歴のあるアクティブユーザ数計測をする
  def update_last_3days_active_count
    start_at = Time.now.ago(3).beginning_of_day
    end_at = Time.now.yesterday.end_of_day
    update_active_count_by_day(3, start_at, end_at)
  end
  
  # 過去７日以内ログインした履歴のあるアクティブユーザ数計測をする
  def update_last_week_active_count
    start_at = Time.now.ago(7).beginning_of_day
    end_at = Time.now.yesterday.end_of_day
    update_active_count_by_day(7, start_at, end_at)
  end
  
  # 過去14日以内ログインした履歴のあるアクティブユーザ数計測をする
  def update_last_14days_active_count
    start_at = Time.now.ago(14).beginning_of_day
    end_at = Time.now.yesterday.end_of_day
    update_active_count_by_day(14, start_at, end_at)
  end
  
  # 過去３０日以内にログインした履歴のあるアクティブユーザ数計測をする
  # 1ヶ月という区切りではなく30日なので注意
  def update_last_30days_active_count
    start_at = Time.now.ago(30).beginning_of_day
    end_at = Time.now.yesterday.end_of_day
    update_active_count_by_day(30, start_at, end_at)
  end
  
  # 指定日時以降にログイン履歴があるユーザ数を計算し履歴として更新する
  # 負荷が高い処理なので再計算は明示的に過去履歴が消されたときのみ行う
  # _param1_:: 履歴とする日付
  # _param2_:: アクティブの対象となる最終ログイン日付 開始
  # _param3_:: アクティブの対象となる最終ログイン日付　終了
  def update_active_count_by_day(before_days, target_start, target_end)
    history_day = Date.today - 1.day
    history = BaseActiveHistory.find_by_history_day_and_before_days(history_day, before_days)
    if history.nil?
      active_count = BaseLatestLogin.find(:all, :conditions => ["app_name = unshiu latest_login >= ? latest_login <= ?  ", target_start.to_i, target_end.to_i]).size
      BaseActiveHistory.create(:before_days => before_days, :history_day => history_day, :user_count => active_count)
    end
    
  rescue Exception => e
    @logger.error "base active history update active count \n #{e}"
  end

end
