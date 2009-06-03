require File.dirname(__FILE__) + '/../test_helper'

module PntHistoryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :pnt_points
        fixtures :pnt_histories
      end
    end
  end
  
  # リレーションのテスト
  def test_relation
    pnt_history = PntHistory.find(1)
    assert_not_nil pnt_history.pnt_point
  end
  
  # 指定ポイントIDの履歴を取得する　find_by_point_histories　のテスト
  def test_find_by_point_histories
    # pnt_point_id = 1の履歴
    pnt_histories = PntHistory.find_by_point_histories(1)
    assert_not_nil pnt_histories
    assert_equal(pnt_histories.size, 2) # 履歴数としては1
    
    # pnt_point_id = 3の履歴
    pnt_histories = PntHistory.find_by_point_histories(3)
    assert_not_nil pnt_histories
    assert_equal(pnt_histories.size, 2) # 履歴数としては2
    
    # pnt_point_id = 999の履歴 
    pnt_histories = PntHistory.find_by_point_histories(999)
    assert_not_nil pnt_histories # nilがかえるわけではない
    assert_equal(pnt_histories.size, 0) # 履歴数としては0
    
  end
  
  # 指定ポイントIDの履歴をpagenateを含んで取得する　find_by_point_histories_with_pagenate　のテスト
  def test_find_by_point_histories_with_pagenate
    
    # pnt_point_id = 3　の履歴を　Max1　件で　1　page　目を取得
    pnt_histories = PntHistory.find_by_point_histories_with_pagenate(3, 1, 1)
    assert_not_nil pnt_histories
    assert_equal(pnt_histories.to_a.size, 1) # 履歴数としては1
    assert_equal(pnt_histories.size, 2) # total size 数としては1
    assert_equal(pnt_histories.to_a[0].id, 1)
    
    # pnt_point_id = 3　の履歴を　Max10　件で　1　page　目を取得
    pnt_histories = PntHistory.find_by_point_histories_with_pagenate(3, 10, 1)
    assert_not_nil pnt_histories
    assert_equal(pnt_histories.to_a.size, 2) # 履歴数としては2
    assert_equal(pnt_histories.to_a[0].id, 1)
    assert_equal(pnt_histories.to_a[1].id, 2)
    
    # pnt_point_id = 3　の履歴を　Max1　件で　2　page　目を取得
    pnt_histories = PntHistory.find_by_point_histories_with_pagenate(3, 1, 2)
    assert_not_nil pnt_histories
    assert_equal(pnt_histories.to_a.size, 1) # 履歴数としては1
    assert_equal(pnt_histories.to_a[0].id, 2)    
  end
  
  # 対象レコードを取得する find_by_period_historiesのテスト
  def test_find_by_period_histories
    # 今月の履歴を取得する
    if Date.today.day == 1
      answer = 1
    elsif Date.today.day <= 2
      answer = 3 # 2日までは 3 が正しい答え
    elsif Date.today.day <= 3
      answer = 5 # 3日までは 5 が正しい答え
    else
      answer = 6 # 3日以降は 6 が正しい答え
    end
    histories = PntHistory.find_by_period_histories(Time.now.beginning_of_month, Time.now.next_month.beginning_of_month - 1)
    assert_equal(histories.size, answer)
    
    # 先月の履歴を取得する
    # 先月のレコード数を取得する
    if Date.today.day == 1
      answer = 8
    elsif Date.today.day <= 3
      answer = 4 # 3日までは 4 が正しい答え
    else
      answer = 3 # 3日以降は 3 が正しい答え
    end
    histories = PntHistory.find_by_period_histories(Time.now.last_month, Time.now.beginning_of_month - 1)
    assert_equal(histories.size, answer)
  end
  
  define_method('test: 発行総ポイント数を取得する') do 
    assert_equal(PntHistory.sum_issue_point, 490) # 発行総ポイントは - 値を含まないので
    
    # 今月の発行総ポイントを取得する
    if Date.today.day == 1
      answer = 0 # 1日は 0 が正しい答え
    elsif Date.today.day <= 2
      answer = 120 # 2日は 120 が正しい答え
    elsif Date.today.day <= 3
      answer = 220 # 3日までは 220 が正しい答え
    else
      answer = 280 # 3日以降は 280 が正しい答え
    end
    assert_equal(PntHistory.sum_issue_point(Time.now.beginning_of_month, Time.now.next_month.beginning_of_month - 1), answer)
    
    # 先月の発行総ポイントを取得する
    if Date.today.day == 1
      answer = 490
    elsif Date.today.day <= 2
      answer = 220 # 2日までは 220 が正しい答え
    elsif Date.today.day <= 3
      answer = 270 # 3日までは 270 が正しい答え
    else
      answer = 210 # 3日以降は 210 が正しい答え
    end
    assert_equal(PntHistory.sum_issue_point(Time.now.last_month, Time.now.beginning_of_month - 1), answer)
  end
  
  # 利用総ポイント数を取得する sum_use_pointのテスト
  def test_sum_use_point
    assert_equal(PntHistory.sum_use_point, 20) # 利用ポイント数なので絶対値がかえる
    
    # 今月の利用総ポイントを取得する
    assert_equal(PntHistory.sum_use_point(Time.now.beginning_of_month, Time.now.next_month.beginning_of_month - 1), 20)
    
    # 先月の利用総ポイントを取得する
    assert_equal(PntHistory.sum_use_point(Time.now.last_month, Time.now.beginning_of_month - 1), 0)
  end

  # 対象レコード数を取得する count_record_countのテスト
  def test_count_record_count
    assert_equal(PntHistory.count_record_count, 9) # 全体で7レコード
    
    # 今月のレコード数を取得する
    if Date.today.day == 1
      answer = 1
    elsif Date.today.day <= 2
      answer = 3 # 2日までは 3 が正しい答え
    elsif Date.today.day <= 3
      answer = 5 # 3日までは 5 が正しい答え
    else
      answer = 6 # 3日以降は 6 が正しい答え
    end
    assert_equal(PntHistory.count_record_count(Time.now.beginning_of_month, Time.now.next_month.beginning_of_month - 1), answer)
    
    # 先月のレコード数を取得する
    if Date.today.day == 1
      answer = 8
    elsif Date.today.day <= 3
      answer = 4 # 3日までは 4 が正しい答え
    else
      answer = 3 # 3日以降は 3 が正しい答え
    end
    assert_equal(PntHistory.count_record_count(Time.now.last_month, Time.now.beginning_of_month - 1), answer)
  end
  
end
