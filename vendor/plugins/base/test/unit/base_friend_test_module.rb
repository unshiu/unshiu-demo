require File.dirname(__FILE__) + '/../test_helper'

module BaseFriendTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_users
        fixtures :base_friends
      end
    end
  end

  # has_many, has_one, belongs_to を宣言したものの呼び出しテスト
  def test_relation
    base_friend = BaseFriend.find(1)
    assert_equal 1, base_friend.base_user.id
    assert_equal 2, base_friend.friend.id
  end
  
  # 友だちを探すテスト
  def test_find_friend
    # 友だち
    assert_not_nil BaseFriend.find_friend(1, 2)
    
    # 申請中
    assert_not_nil BaseFriend.find_friend(1, 3)
    
    # 友だちじゃないユーザー
    assert_nil BaseFriend.find_friend(1, 4)
    
    # 存在しないユーザー
    assert_nil BaseFriend.find_friend(1, 100)
  end

  # 逆を探すテスト
  def test_find_reverse
    # 基準となるものを取得
    friend = BaseFriend.find_friend(1, 2)
    assert_not_nil friend
    
    # 逆を取得
    reverse = friend.find_reverse    
    assert_not_nil reverse
    
    # id が逆になっているか確認
    assert_equal 2, reverse.base_user_id
    assert_equal 1, reverse.friend_id
    
    # 基準となるものを取得（申請中）
    friend = BaseFriend.find_friend(1, 3)
    assert_not_nil friend
    
    # 逆を取得
    reverse = friend.find_reverse
    assert_nil reverse # 申請中なので逆はない
  end

  # 友だち追加のテスト
  def test_add
    # まだ友だちじゃない
    assert_nil BaseFriend.find_friend(1, 4) # ないことを確認
    BaseFriend.add(1, 4) # 作成
    assert_not_nil BaseFriend.find_friend(1, 4) # あることを確認
    
    # すでに友だち
    assert BaseFriend.add(1, 2).is_a?(String) # エラーメッセージが String で返ってくる
    
    # 申請中
    assert BaseFriend.add(1, 3).is_a?(String) # エラーメッセージが String で返ってくる
    
    # ユーザーが存在しない
    assert BaseFriend.add(1, 100).is_a?(String) # エラーメッセージが String で返ってくる
  end
  
  # 友だち判定のテスト
  def test_friend?
    # 友だち
    assert BaseFriend.friend?(1, 2)
    
    # 逆もチェック
    assert BaseFriend.friend?(2, 1)
    
    # 申請中
    assert !BaseFriend.friend?(1, 3) # 申請中はまだ友だちじゃない
    
    # 友だちじゃない
    assert !BaseFriend.friend?(1, 4)
    
    # 存在しないユーザー
    assert !BaseFriend.friend?(1, 100)
  end

  # 友だちか申請中か判定するテスト
  def test_friend_or_applying?
    # 友だち
    assert BaseFriend.friend_or_applying?(1, 2)
    
    # 逆もチェック
    assert BaseFriend.friend_or_applying?(2, 1)
    
    # 申請中
    assert BaseFriend.friend_or_applying?(1, 3) # 申請中もひっかかる
    
    # 友だちじゃない
    assert !BaseFriend.friend_or_applying?(1, 4)
    
    # 存在しないユーザー
    assert !BaseFriend.friend_or_applying?(1, 100)
  end
  
  # 申請を許可するテスト
  def test_permit
    # 申請中のやつを適当に取得
    friend = BaseFriend.find_by_status(BaseFriend::STATUS_APPLYING)
    friend.permit
    
    # 申請中から友だちになったか確認
    assert_equal BaseFriend::STATUS_FRIEND, friend.status
    # 逆が作られて友だちになっているか確認
    reverse = friend.find_reverse
    assert_not_nil reverse
    assert_equal BaseFriend::STATUS_FRIEND, reverse.status
  end
  
  # 申請を拒否するテスト
  def test_deny
    # 申請中のやつを適当に取得
    friend = BaseFriend.find_by_status(BaseFriend::STATUS_APPLYING)
    friend.deny
    
    # 申請が消えているか確認
    assert_raise(ActiveRecord::RecordNotFound){
      BaseFriend.find(friend.id)
    }
  end

end