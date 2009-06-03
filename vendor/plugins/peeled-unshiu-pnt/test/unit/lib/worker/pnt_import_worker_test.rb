require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/pnt_import_worker"
 
# 1クラス内で複数メソッドでテストするとうまくうごかなかったので
# クラスごとわけてみた
module PntImportWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        self.use_transactional_fixtures = false
        
        fixtures :base_users
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :pnt_histories
        fixtures :pnt_file_update_histories
      end
    end
  end
  
  # 全レコードが正常に追加処理される場合のテスト
  def test_add_import_file
    test_target_file_name = 'pnt_import_csv_test_add_import_file.txt'
    
    # base_user = 1, 2 に 100ポイントづつ追加処理がされる
    worker = PntImportWorker.new
    worker.import(test_target_file_name)
    
    # ポイントの増加処理を確認
    assert_equal(PntPoint.find_base_user_point(1, 1).point, 200)
    assert_equal(PntPoint.find_base_user_point(1, 2).point, 250)
    
    # ポイント履歴追加を確認
    history = PntHistory.find(:first, :conditions => ["message = '一括追加テストレコード1'"] )
    assert_not_nil history
    assert_equal(history.difference, 100)
    assert_equal(history.amount, 200)
    
    history = PntHistory.find(:first, :conditions => ["message = '一括追加テストレコード2'"] )
    assert_not_nil history
    assert_equal(history.difference, 50)
    assert_equal(history.amount, 250)
    
    # 一括処理レコードの更新を確認
    file_history = PntFileUpdateHistory.find(:first, :conditions => ["file_name = ?", test_target_file_name] )
    assert_not_nil file_history
    assert_equal(file_history.record_count, 2)
    assert_equal(file_history.success_count, 2)
    assert_equal(file_history.fail_count, 0)
    assert_not_nil file_history.complated_at # 完了
  end
  
end

