require File.dirname(__FILE__) + '/../test_helper'

module MlgMagazineTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mlg_deliveries
        fixtures :mlg_magazines
      end
    end
  end
  
  # まだ未配達かつ、送信処理時刻をすぎているメールマガジンを取得する
  # find_process_target_delivery_magazine メソッドのテスト
  def test_find_process_target_delivery_magazines
    
    magazines = MlgMagazine.find_process_target_delivery_magazines
    assert_equal(magazines.size, 1) # 未配達は1件のみ
    assert_equal(magazines[0].id, 1)
    
  end
  
  # 送信済みかどうかをかえす send_setup? のテスト
  def test_send_setup?
    
    # 送信日が昨日のメールマガジン
    magazines = MlgMagazine.find(1)
    assert_equal(magazines.send_setup?, true) # 設定は完了している
    
    # まだ送信設定されてないメールマガジン
    magazines = MlgMagazine.find(5)
    assert_equal(magazines.send_setup?, false) # 設定は完了してない
    
  end
   
  # 削除可能かどうかをかえす deletable? のテスト
  def test_deletable?
    # 送信日が昨日のメールマガジン
    magazines = MlgMagazine.find(1)
    assert_equal(magazines.deletable?, false)
    
    # 送信日が明日のメールマガジン
    magazines = MlgMagazine.find(4)
    assert_equal(magazines.deletable?, true)
    
    # まだ送信設定されてないメールマガジン
    magazines = MlgMagazine.find(5)
    assert_equal(magazines.deletable?, true)
    
  end
  
  # MlgMagazine class 情報から 配信数を取得する send_count のテスト
  def test_send_count
    
    # mlg_magazine_id = 1 の配達数は 1
    magazines = MlgMagazine.find(1)
    assert_equal(magazines.send_count, 1) 
    
    # mlg_magazine_id = 3 の配達数は 3
    magazines = MlgMagazine.find(3)
    assert_equal(magazines.send_count, 3)
  end
end
