require File.dirname(__FILE__) + '/../test_helper'

module MlgDeliveryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mlg_deliveries
        fixtures :base_users
      end
    end
  end
  
  # 指定メールマガジンの送信対象者を１件取得する find_target_deliverのテスト
  def test_find_target_delivers
    
    delivers = MlgDelivery.find_target_delivers(1)
    assert_not_nil delivers # 対象はいる
    assert_equal(delivers.size, 1) 
    assert_equal(delivers[0].base_user_id.to_i, 1)
    assert_equal(delivers[0].class.name, 'BaseUser') # かえってくるのはbase_userクラス
  end
  
  # 指定メールマガジンの送信対象者数を取得する count_target_deliversのテスト
  def test_count_target_delivers
    # mlg_magazine_id = 1 の配達数は 1
    count = MlgDelivery.count_target_delivers(1)
    assert_equal(count, 1)
    
    # mlg_magazine_id = 3 の配達数は 3
    count = MlgDelivery.count_target_delivers(3)
    assert_equal(count, 3) 
  end
  
  # 指定メールマガジンの送信対象者を送信済みにする update_sended_target_delivers のテスト
  def test_update_sended_target_delivers
    # 1件ずつ処理する状態になっているか確認
    assert_equal 1, MlgDelivery::TARGET_LIMIT
    
    # 未配信が3つある
    assert_equal 3, MlgDelivery.find_all_by_mlg_magazine_id_and_sended_at(3, nil).size
    
    # 1つめを処理する
    delivers1 = MlgDelivery.find_target_delivers(3)
    assert_not_nil delivers1
    assert_equal(delivers1.size, 1)
    assert_equal(delivers1[0].mlg_delivery_id.to_i, 4)
    assert_equal(delivers1[0].base_user_id.to_i, 1)
    
    last_id = delivers1.last.mlg_delivery_id
    MlgDelivery.update_sended_target_delivers(3, last_id)
    
    # 未配信が2つある
    assert_equal 2, MlgDelivery.find_all_by_mlg_magazine_id_and_sended_at(3, nil).size
    
    # 2つめを処理する
    delivers2 = MlgDelivery.find_target_delivers(3)
    assert_not_nil delivers2
    assert_equal(delivers2.size, 1)
    assert_equal(delivers2[0].mlg_delivery_id.to_i, 6)
    assert_equal(delivers2[0].base_user_id.to_i, 3)
    
    last_id = delivers2.last.mlg_delivery_id
    MlgDelivery.update_sended_target_delivers(3, last_id)
    
    # 未配信が0になっている
    assert_equal 0, MlgDelivery.find_all_by_mlg_magazine_id_and_sended_at(3, nil).size
  end
end
