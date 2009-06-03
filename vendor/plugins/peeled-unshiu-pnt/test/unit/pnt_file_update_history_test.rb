require File.dirname(__FILE__) + '/../test_helper'

module PntFileUpdateHistoryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :pnt_file_update_histories
      end
    end
  end
  
  # リレーションのテスト
  def test_relation
    pnt_file_update_history = PntFileUpdateHistory.find(1)
    assert_not_nil pnt_file_update_history
  end
  
  # 処理が完了しているかどうかを判断する complated? のテスト
  # 処理が終了してるかどうかは　complated_atがnilでないかどうかで判断する
  def test_complated?
    
    # id = 1 は既に処理が完了している
    pnt_file_update_history = PntFileUpdateHistory.find(1)
    assert_equal(pnt_file_update_history.complated?, true)
  
    # id = 3 はまだ処理中
    pnt_file_update_history = PntFileUpdateHistory.find(3)
    assert_equal(pnt_file_update_history.complated?, false)
  
  end
  
end
