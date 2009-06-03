require File.dirname(__FILE__) + '/../test_helper'

module PntHistorySummaryTestModule
  
  class << self
    def included(base)
      base.class_eval do
       fixtures :pnt_history_summaries
      end
    end
  end
  
  # リレーションのテスト
  def test_relation
    pnt_summary = PntHistorySummary.find(1)
  end
  
  # 指定範囲の集計履歴を取得する　find_by_period_summaryのテスト
  def test_find_by_period_summarys
    
    # 対象をfixutureでロード済みなのでレコードがある
    start_at = Time.now.last_month
    end_at = Time.now.beginning_of_month - 1
    pnt_summary = PntHistorySummary.find_by_period_summary(start_at, end_at)
    assert_not_nil pnt_summary
    
    # 対象はないのでnilがかえる
    start_at = Time.now
    end_at = Time.now
    pnt_summary = PntHistorySummary.find_by_period_summary(start_at, end_at)
    assert_nil pnt_summary
  end
  
  # 月別の集計結果を取得する　find_by_month_summaries　のテスト
  def test_find_by_month_summaries
    # 月別レコードは 全 3件のうち2件のみだから
    summaries = PntHistorySummary.find_by_month_summaries
    assert_equal(summaries.size, 2)
  end
  
  # ファイルのパスを含めて取得する file_path のテスト
  def test_file_path
    summary = PntHistorySummary.find(1)
    fullpath = RAILS_ROOT + "/public/system/files/pnt/" + summary.file_name
    assert_equal(summary.file_path, fullpath)
  end
end
