require File.dirname(__FILE__) + '/../test_helper'

module DiaEntryCommentTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
      end
    end
  end
  
  # 関連付けのテスト
  def test_relation
    dia_entry_comment = DiaEntryComment.find(1)
    assert_not_nil dia_entry_comment.base_user
    assert_not_nil dia_entry_comment.dia_entry
  end

  # 自分が書いたコメントかチェックのテスト
  def test_mine?
    current_base_user = BaseUser.find(1)
    
    # 書いたコメントの場合
    dia_entry_comment = DiaEntryComment.find(1)
    assert dia_entry_comment.mine?(current_base_user)

    # 書いてないコメントの場合
    dia_entry_comment = DiaEntryComment.find(3)
    assert !dia_entry_comment.mine?(current_base_user)
    
    # 非ログインユーザーの場合
    assert !dia_entry_comment.mine?(:false)
  end  
  
  # 削除可能なコメントかチェックするテスト
  def test_deletable?
    current_base_user = BaseUser.find(1)
    
    # 日記記事の所有者な場合
    dia_entry_comment = DiaEntryComment.find(2)
    assert dia_entry_comment.deletable?(current_base_user)

    # 書いたコメントの場合
    dia_entry_comment = DiaEntryComment.find(1)
    assert dia_entry_comment.deletable?(current_base_user)

    # どちらでもない場合
    dia_entry_comment = DiaEntryComment.find(3)
    assert !dia_entry_comment.deletable?(current_base_user)

    # 非ログインユーザーの場合
    assert !dia_entry_comment.deletable?(:false)
  end
  
  # 未読コメントの数のテスト
  def test_count_unread_entry_comments_by_base_user_id
    current_base_user_id = 1
    assert_equal 2, DiaEntryComment.count_unread_entry_comments_by_base_user_id(current_base_user_id)

    current_base_user_id = 2
    assert_equal 1, DiaEntryComment.count_unread_entry_comments_by_base_user_id(current_base_user_id)
  end

  # 未読コメントの中で一番古いコメントを返すテスト
  def test_find_oldest_unread_comment_by_base_user_id
    current_base_user_id = 1
    assert_equal 4, DiaEntryComment.find_oldest_unread_comment_by_base_user_id(current_base_user_id).id
  end
  
  # base_user が entry_owner と同一であれば、
  # comments の read_flag を true にする
  def test_to_read_if_entry_owner
    # 記事投稿者以外のアクセス
    current_base_user = BaseUser.find(2)
    entry_owner_id = 1
    comments = DiaEntryComment.find([2,4,5,6])    
    DiaEntryComment.to_read_if_entry_owner(current_base_user, entry_owner_id, comments)
    assert_not_equal 0, DiaEntryComment.count_unread_entry_comments_by_base_user_id(entry_owner_id)

    # 記事投稿者のアクセス
    current_base_user = BaseUser.find(1)
    DiaEntryComment.to_read_if_entry_owner(current_base_user, entry_owner_id, comments)
    assert_equal 0, DiaEntryComment.count_unread_entry_comments_by_base_user_id(entry_owner_id)
  end
  
  # 以下、Deleter のテスト。。。ここにあるのはおかしいのだが。。。
  # 不可視化するテスト
  def test_invisibled_by
    comment = DiaEntryComment.find(:first)
    base_user_id = 1
    comment.invisible_by(base_user_id)
    assert_equal base_user_id, comment.invisibled_by
  end

  # 可視化するテスト
  def test_cancel_invisibled_by
    comment = DiaEntryComment.find(:first)
    comment.cancel_invisibled
    assert_equal nil, comment.invisibled_by
  end
  
  def test_invisibled_by_anyone?
    comment = DiaEntryComment.find(:first)
    assert !comment.invisibled_by_anyone?
    base_user_id = 1
    comment.invisible_by(base_user_id)
    assert comment.invisibled_by_anyone?
  end
  
  def test_invisibled_by_writer?
    comment = DiaEntryComment.find(:first)
    assert !comment.invisibled_by_writer?
    comment.invisible_by(comment.base_user_id)
    assert comment.invisibled_by_writer?
  end

  def test_invisibled_by_owner?
    comment = DiaEntryComment.find(:first)
    assert !comment.invisibled_by_writer?
    comment.invisible_by(comment.dia_entry.dia_diary.base_user_id)
    assert comment.invisibled_by_owner?
  end
  
  def test_invisibled_by_manager?
    comment = DiaEntryComment.find(:first)
    assert !comment.invisibled_by_manager?
    base_user_id = 1
    comment.invisible_by(base_user_id)
    assert comment.invisibled_by_manager?
  end

  def test_not_invisibled_by_anyone?
    comment = DiaEntryComment.find(:first)
    base_user_id = 1
    comment.invisible_by(base_user_id)
    assert !comment.not_invisibled_by_anyone?
    comment.cancel_invisibled
    assert comment.not_invisibled_by_anyone?
  end
  
  define_method('test: コメントを新規作成すると記事最終更新日時が更新される') do 
    before_lasted_comment = DiaEntry.find_by_id(1).last_commented_at
    sleep(1)
    
    comment = DiaEntryComment.new({:base_user_id => 1, :dia_entry_id => 1, :body => "test create"})
    comment.save
    assert_not_equal(before_lasted_comment, DiaEntry.find_by_id(1).last_commented_at) # 更新されているので違う
  end
  
  define_method('test: accesible_comments はアクセス可能な記事のコメント一覧を取得する') do 
    dia_diary = DiaDiary.find(1)
    
    # 自分
    base_user = BaseUser.find(1)
    comments = DiaEntryComment.accesible_comments(dia_diary, base_user)
    
    assert_not_nil(comments)
    assert_not_equal(comments.size, 0)
    comments.each do |comment|
      assert(UserRelationSystem.accessible?(base_user, 1, comment.dia_entry.public_level))
    end
    
    # 友だち
    base_user = BaseUser.find(2)
    comments = DiaEntryComment.accesible_comments(dia_diary, base_user)
    
    assert_not_nil(comments)
    assert_not_equal(comments.size, 0)
    comments.each do |comment|
      assert(UserRelationSystem.accessible?(base_user, 1, comment.dia_entry.public_level))
    end

    # 友だちの友だち
    base_user = BaseUser.find(4)
    comments = DiaEntryComment.accesible_comments(dia_diary, base_user)
    
    assert_not_nil(comments)
    assert_not_equal(comments.size, 0)
    comments.each do |comment|
      assert(UserRelationSystem.accessible?(base_user, 1, comment.dia_entry.public_level))
    end

    # ログインユーザー
    base_user = BaseUser.find(3)
    comments = DiaEntryComment.accesible_comments(dia_diary, base_user)
    
    assert_not_nil(comments)
    assert_not_equal(comments.size, 0)
    comments.each do |comment|
      assert(UserRelationSystem.accessible?(base_user, 1, comment.dia_entry.public_level))
    end
    
    # ログインしていないユーザー
    base_user = :false
    comments = DiaEntryComment.accesible_comments(dia_diary, base_user)
    
    assert_not_nil(comments)
    assert_not_equal(comments.size, 0)
    comments.each do |comment|
      assert(UserRelationSystem.accessible?(base_user, 1, comment.dia_entry.public_level))
    end
  end
  
end
