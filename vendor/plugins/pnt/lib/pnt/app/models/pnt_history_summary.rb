# == Schema Information
#
# Table name: pnt_history_summaries
#
#  id              :integer(4)      not null, primary key
#  start_at        :datetime        not null
#  end_at          :datetime        not null
#  sum_issue_point :integer(4)      not null
#  sum_use_point   :integer(4)      not null
#  record_count    :integer(4)      not null
#  file_name       :string(256)     default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  kind_type       :integer(4)      not null
#

module PntHistorySummaryModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        # kind_type column の定数値
        const_set('KIND_TYPE_FREE',      0)
        const_set('KIND_TYPE_DAY',       1)
        const_set('KIND_TYPE_WEEK',      2)
        const_set('KIND_TYPE_MONTH',     3)
        const_set('KIND_TYPE_QUARTER',   4)
        const_set('KIND_TYPE_HALF_YEAR', 5)
        const_set('KIND_TYPE_YEAR',      6)
        
      end
    end
  end
  
  # ファイルの保存フルパスを返す
  def file_path
    RAILS_ROOT + "/" + AppResources['pnt']['history_file_path'] + "/" + self.file_name
  end
  
  module ClassMethods
    # 指定範囲の集計履歴を取得する。まだ未作成ならnilがかえる
    # _param1_:: start_at 集計処理対象開始日
    # _param2_:: end_at   集計処理対象終了日
    # return  :: 集計履歴
    def find_by_period_summary(start_at, end_at)
      find(:first, :conditions => [' start_at = ? and end_at = ? ', start_at, end_at])
    end
  
    # 月別の集計履歴を取得する。
    # return  :: 集計履歴
    def find_by_month_summaries
      find(:all, :conditions => [' kind_type = ? ', PntHistorySummary::KIND_TYPE_MONTH])
    end
  end

end
