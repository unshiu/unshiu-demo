require File.dirname(__FILE__) + '/../test_helper'

module PntFilterTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :pnt_filter_masters
        fixtures :pnt_masters
        fixtures :pnt_filters
      end
    end
  end
  
  # リレーションのテスト
  def test_relation
    pnt_filter = PntFilter.find(1)
    assert_not_nil pnt_filter.pnt_master
  end
  
  # ポイントマスタごとのフィルタを取得する　find_pnt_master_filters　のテスト
  def test_find_pnt_master_filters
    # master_id = 1 のフィルタ取得
    pnt_filters = PntFilter.find_pnt_master_filters(1) 
    assert_equal(pnt_filters.size, 7) # 7つ存在する
    
    # master_id = 999 のフィルタ取得
    pnt_filters = PntFilter.find_pnt_master_filters(999) 
    assert_equal(pnt_filters.size, 0) # 存在しない
  end
  
  # 各処理にフィルタが存在を取得する find_target_filters のテスト
  def test_find_target_filters
    pnt_filters = PntFilter.find_target_filters('point_system_test', 'target')
    assert_equal(pnt_filters.size, 1) # 1つ存在する
    
    pnt_filters = PntFilter.find_target_filters('point_system_test', 'testtettest')
    assert_equal(pnt_filters.size, 0) # 存在しない
  end
  
  # 有効なフィルターを取得しなおす lock_if_active のテスト
  def test_lock_if_active
    pnt_filter = PntFilter.lock_if_active(2, 100)
    assert_not_nil pnt_filter
    pnt_filter.save
    
    pnt_filter = PntFilter.lock_if_active(2, 10000)
    assert_nil pnt_filter
  end
  
  # フィルタ情報を更新する際にlockが必要かどうかをかえす　use_lock?のテスト
  def test_use_lock?
    pnt_filter = PntFilter.find(1)
    assert_equal(pnt_filter.use_lock?, false) # 配布上限がない
    
    pnt_filter = PntFilter.find(2)
    assert_equal(pnt_filter.use_lock?, true) # 配布上限がある
  end
  
  # 配布上限が設けられているか has_limit? のテスト
  # use_lock? の alias なので必要ないと言えばないんだが、一応テストしておく
  def test_has_limit?
    pnt_filter = PntFilter.find(1)
    assert_equal(pnt_filter.has_limit?, false) # 配布上限がない
    
    pnt_filter = PntFilter.find(2)
    assert_equal(pnt_filter.has_limit?, true) # 配布上限がある
  end
  
  # 表示用配布上限 show_limit のテスト
  def test_has_limit?
    pnt_filter = PntFilter.find(1)
    assert pnt_filter.show_limit.empty? # 配布上限がないときは、空の文字列
    
    pnt_filter = PntFilter.find(2)
    assert_equal(pnt_filter.show_limit, pnt_filter.stock) # 配布上限があるときは、上限の値
  end
end
