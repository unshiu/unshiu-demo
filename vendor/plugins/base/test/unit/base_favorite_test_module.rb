require File.dirname(__FILE__) + '/../test_helper'

module BaseFavoriteTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_users
        fixtures :base_favorites
      end
    end
  end

  def test_relation
    base_favorite = BaseFavorite.find(1)
    assert_equal 1, base_favorite.base_user.id
    assert_equal 2, base_favorite.favorite.id
  end

  # お気に入りを探すテスト
  def test_find_by_ids
    # 存在する
    assert_not_nil BaseFavorite.find_by_ids(1, 2)
    
    # 存在しない
    assert_nil BaseFavorite.find_by_ids(2, 3)
  end

  # 追加のテスト
  def test_add
    # 新規
    result = BaseFavorite.add(2, 3)
    assert result # save の結果として true が返ってくるはず
    
    # 既存
    result = BaseFavorite.add(1, 2)
    assert result.is_a?(String) # エラーになってメッセージが返ってくるはず
  end
  
  # お気に入りチェックのテスト
  def test_favorite?
    # お気に入り
    assert BaseFavorite.favorite?(1, 2)
    
    # お気に入りじゃない
    assert !BaseFavorite.favorite?(2, 3)
  end

end