require File.dirname(__FILE__) + '/../test_helper'

module DiaDiaryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :base_users
      end
    end
  end
  
  # 関連付けのテスト
  def test_relation
    dia_diary = DiaDiary.find(1)
    assert_not_nil dia_diary.base_user
    assert_not_nil dia_diary.dia_entries
    assert_not_nil dia_diary.dia_draft_entries
  end
  
  # 日記を探して、なかったら作るテスト
  def test_find_or_create
    # すでに日記があるユーザー
    diary = DiaDiary.find_or_create(1)
    assert_not_nil diary
    assert_equal 1, diary.id
    
    # 日記がまだないユーザー
    diary = DiaDiary.find_or_create(10)
    assert_not_nil diary
  end
  
  # 日記を作るテスト
  def test_create
    # 日記を作る
    DiaDiary.create(3)
    
    # 作ったものがあるか確認
    assert_not_nil DiaDiary.find_by_base_user_id(3)
  end

  # 日記の所有者かチェックするテスト
  def test_mine?
    current_base_user = BaseUser.find(1)
    
    # 自分の日記の場合
    dia_diary = DiaDiary.find(1)
    assert dia_diary.mine?(current_base_user)

    # 自分の日記じゃない場合
    dia_diary = DiaDiary.find(2)
    assert !dia_diary.mine?(current_base_user)
  end
  
  define_method('test: accesible_entries はアクセス可能な記事を取得する') do 
    owner_id = 1
    dia_diary = DiaDiary.find_by_base_user_id(owner_id)
    
    # 自分
    current_base_user = BaseUser.find(1)
    assert_not_nil entries = dia_diary.accesible_entries(current_base_user)
    assert_equal 5, entries.size
    entries.each do |entry|
      UserRelationSystem.accessible?(current_base_user, owner_id, entry.public_level)
    end
    
    # 友だち
    current_base_user = BaseUser.find(2)
    assert_not_nil entries = dia_diary.accesible_entries(current_base_user)
    assert_equal 5, entries.size
    entries.each do |entry|
      UserRelationSystem.accessible?(current_base_user, owner_id, entry.public_level)
    end
    
    # 友だちの友だち
    current_base_user = BaseUser.find(4)
    assert_not_nil entries = dia_diary.accesible_entries(current_base_user)
    assert_equal 4, entries.size
    entries.each do |entry|
      UserRelationSystem.accessible?(current_base_user, owner_id, entry.public_level)
    end
    
    # ログインユーザー
    current_base_user = BaseUser.find(3)
    assert_not_nil entries = dia_diary.accesible_entries(current_base_user)
    assert_equal 3, entries.size
    entries.each do |entry|
      UserRelationSystem.accessible?(current_base_user, owner_id, entry.public_level)
    end

    # ログインしていないユーザー
    current_base_user = :false
    assert_not_nil entries = dia_diary.accesible_entries(current_base_user)
    assert_equal 2, entries.size
    entries.each do |entry|
      UserRelationSystem.accessible?(current_base_user, owner_id, entry.public_level)
    end
  end
  
end
