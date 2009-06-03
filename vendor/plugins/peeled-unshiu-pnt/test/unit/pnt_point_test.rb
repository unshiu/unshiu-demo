require File.dirname(__FILE__) + '/../test_helper'

module PntPointTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :pnt_points
        fixtures :pnt_histories
        fixtures :base_users
      end
    end
  end

  # リレーションのテスト
  def test_relation
    pnt_point = PntPoint.find(1)
    assert_not_nil pnt_point.base_user
    assert_not_nil pnt_point.pnt_master
    assert_not_nil pnt_point.pnt_histories
  end
  
  # validationのテスト
  def test_validation
    pnt_point = PntPoint.new
    assert_equal(pnt_point.valid?, false) # 空では作成不可能 
    pnt_point.base_user_id = 1 
    assert_equal(pnt_point.valid?, false) # base_user_id追加でもだめ
    pnt_point.point = 0
    assert_equal(pnt_point.valid?, false) # point追加でもまだだめ
    pnt_point.pnt_master_id = 1
    assert_equal(pnt_point.valid?, true)  # pnt_master_idを追加すればOK
    
    pnt_point.point = -10
    assert_equal(pnt_point.valid?, false) # ポイントがマイナスは認めない
  end
  
  # レコードを pnt_master_id と base_user_idで検索しあったらそのレコードをかえして
  # ポイント0状態のレコードを生成する find_or_create_base_user_point メソッドのテスト
  def test_find_or_create_base_user_point
    pnt_point = PntPoint.find_or_create_base_user_point(999, 999)
    
    assert_not_nil pnt_point # classは生成されている
    assert_equal(pnt_point.pnt_master_id, 999) 
    assert_equal(pnt_point.base_user_id, 999)
    assert_equal(pnt_point.point.to_i, 0) #　初期状態のポイントは0
    
  end
  
  define_method('test: ユーザの現在の総ポイント数を返す') do 
    # user_id = 1のポイント　-> 100+300
    assert_equal(PntPoint.base_user_all_point(1), 400)
    # user_id = 2のポイント　-> 200
    assert_equal(PntPoint.base_user_all_point(2), 200)
    # logがない場合は 0 が返る
    assert_equal(PntPoint.base_user_all_point(9999), 0)
  end
  
  # ユーザのポイント情報をかえす、find_base_user_pointメソッドのテスト
  def test_find_base_user_point
    # pnt_master_id = 1, user_id = 1 のポイント情報取得 
    pnt_point = PntPoint.find_base_user_point(1, 1)
    assert_not_nil pnt_point
    assert_equal(pnt_point.point, 100)
    
    # pnt_master_id = 1, user_id = 2 のポイント情報取得 
    pnt_point = PntPoint.find_base_user_point(1, 2)
    assert_not_nil pnt_point
    assert_equal(pnt_point.point, 200)
    
    # pnt_master_id = 999, user_id = 1 のポイント情報取得 
    pnt_point = PntPoint.find_base_user_point(999, 1) 
    assert_nil pnt_point #テストレコードにないはず
  end
  
  # ユーザがもっている各ポイント情報をかえす、find_base_user_pointsメソッドのテスト
  def test_find_base_user_points
    # user_id = 1 のポイント情報取得 
    pnt_points = PntPoint.find_base_user_points(1)
    assert_not_nil pnt_points
    assert_equal(pnt_points.size, 2) # 2つのポイントを保持している
    
    # user_id = 2 のポイント情報取得 
    pnt_points = PntPoint.find_base_user_points(2)
    assert_not_nil pnt_points
    assert_equal(pnt_points.size, 1) # 1つのポイントを保持している
  end
end
