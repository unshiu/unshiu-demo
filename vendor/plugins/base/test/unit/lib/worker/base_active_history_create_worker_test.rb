require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/base_active_history_create_worker"

module BaseActiveHistoryCreateWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_active_histories
      end
    end
  end
  
  define_method('test: 前日のアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'BaseActiveHistory.count', 1 do 
      worker = BaseActiveHistoryCreateWorker.new
      worker.update_yesterday_active_count
    end
    
    history = BaseActiveHistory.find(:first, :conditions => ['history_day = ? and before_days = 1 ', Date.today - 1.day])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
  define_method('test: 3日以内にのアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'BaseActiveHistory.count', 1 do 
      worker = BaseActiveHistoryCreateWorker.new
      worker.update_last_3days_active_count
    end
    
    history = BaseActiveHistory.find(:first, :conditions => ['history_day = ? and before_days = 3 ', Date.today - 1.day])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
  define_method('test: 過去7日以内にログインしたアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'BaseActiveHistory.count', 1 do 
      worker = BaseActiveHistoryCreateWorker.new
      worker.update_last_week_active_count 
    end
    
    history = BaseActiveHistory.find(:first, :conditions => ['history_day = ? and before_days = 7 ', Date.today - 1.day])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
  define_method('test: 過去14日以内にログインしたアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'BaseActiveHistory.count', 1 do 
      worker = BaseActiveHistoryCreateWorker.new
      worker.update_last_14days_active_count 
    end
    
    history = BaseActiveHistory.find(:first, :conditions => ['history_day = ? and before_days = 14 ', Date.today - 1.day])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
  define_method('test: 過去30日以内にログインしたアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'BaseActiveHistory.count', 1 do 
      worker = BaseActiveHistoryCreateWorker.new
      worker.update_last_30days_active_count 
    end
    
    history = BaseActiveHistory.find(:first, :conditions => ['history_day = ? and before_days = 30 ', Date.today - 1.day])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
end