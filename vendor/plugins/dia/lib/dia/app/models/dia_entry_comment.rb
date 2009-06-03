# == Schema Information
#
# Table name: dia_entry_comments
#
#  id            :integer(4)      not null, primary key
#  base_user_id  :integer(4)      not null
#  dia_entry_id  :integer(4)      not null
#  body          :text
#  created_at    :datetime
#  updated_at    :datetime
#  read_flag     :boolean(1)      not null
#  invisibled_by :integer(4)
#

module DiaEntryCommentModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_invisible :dia_entry => :dia_diary
        
        belongs_to :dia_entry
        belongs_to :base_user

        validates_presence_of :body
        validates_good_word_of :body
        validates_length_of :body, :maximum => AppResources['base']['comment_max_length']
        
        after_save :update_dia_entry_last_commented_at
        
        named_scope :dia_diary_comments, lambda { |dia_diary_id| 
          {:include => [:dia_entry], :conditions => ["dia_entries.dia_diary_id = ?", dia_diary_id], :order => ['dia_entry_comments.created_at desc']} 
        }
        
        # 日記の持ち主がアクセス可能な記事のコメント
        named_scope :owner_accesible, :order => ['dia_entries.updated_at desc']
        
        # 友だちの友だちにがアクセス可能な記事のコメント
        named_scope :foaf_accesible, :conditions => ["dia_entries.public_level not in (?)", [UserRelationSystem::PUBLIC_LEVEL_ME, UserRelationSystem::PUBLIC_LEVEL_FRIEND]], 
                                     :order => ['dia_entries.updated_at desc'] 
        
        # 友達ではないユーザがアクセス可能な記事のコメント
        named_scope :uncontacts_user_accesible, :conditions => ["dia_entries.public_level not in (?)", [UserRelationSystem::PUBLIC_LEVEL_ME, UserRelationSystem::PUBLIC_LEVEL_FRIEND, UserRelationSystem::PUBLIC_LEVEL_FOAF]], 
                                                :order => ['dia_entries.updated_at desc']
                                                
        # 非ユーザがアクセス可能な記事のコメント
        named_scope :unuser_accesible, :conditions => ["dia_entries.public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL], 
                                       :order => ['dia_entries.updated_at desc']
      end
    end
  end
  
  # 自分が書いたコメントかチェック
  # _base_user_:: アクセスユーザー
  # _return_:: 自分が書いたコメントなら true、それ以外なら false
  def mine?(base_user)
    if base_user && base_user != :false # means logged_in?
      self.base_user_id == base_user.id
    else
      false
    end
  end

  # 削除権限があるコメントかチェック
  # _base_user_:: アクセスユーザー
  # _return_:: 自分が書いたコメントか、日記記事の所有者なら true、それ以外なら false
  def deletable?(base_user)
    if self.mine?(base_user)
      return true
    elsif self.dia_entry.mine?(base_user)
      return true
    else
      return false
    end
  end

private

  def update_dia_entry_last_commented_at
    self.dia_entry.last_commented_at = self.updated_at
    self.dia_entry.save
  end
  
  module ClassMethods
    
    # base_user がアクセス可能なこの日記の記事のコメントを返す
    # _param1_:: 日記
    # _param2_:: アクセスユーザー
    # _return_:: base_user がアクセス可能なこの日記の記事
    def accesible_comments(dia_diary, base_user)
      owner_id = dia_diary.base_user_id
      
      if base_user && base_user != :false # means logged_in?
        if base_user.me?(owner_id) || base_user.friend?(owner_id)
          dia_diary_comments(dia_diary.id).owner_accesible

        elsif base_user.foaf?(owner_id)
          dia_diary_comments(dia_diary.id).foaf_accesible

        else
          dia_diary_comments(dia_diary.id).uncontacts_user_accesible
        end
      else
        dia_diary_comments(dia_diary.id).unuser_accesible
      end
    end
    
    # 未読コメントの数
    def count_unread_entry_comments_by_base_user_id(base_user_id)
      count(:include => {:dia_entry => :dia_diary},
            :conditions => ['dia_diaries.base_user_id = ? and read_flag != true and dia_entries.draft_flag != true', base_user_id])
    end

    # ユーザーの未読コメントの中で一番古いコメントを返す
    # _base_user_:: アクセスユーザーのID
    def find_oldest_unread_comment_by_base_user_id(base_user_id)
      find(:first, :include => {:dia_entry => :dia_diary},
           :conditions => ['dia_diaries.base_user_id = ? and read_flag != true and dia_entries.draft_flag != true', base_user_id],
           :order => 'dia_entry_comments.created_at')
    end
  
    # base_user が entry_owner と同一であれば、
    # comments の read_flag を true にする
    # ちなみに、メソッド名の read は過去形です
    # _base_user_:: アクセスユーザー
    # _entry_owner_:: 日記記事の所有者
    # _comments_:: 閲覧したコメント
    def to_read_if_entry_owner(base_user, entry_owner_id, comments)
      if base_user != :false && base_user.me?(entry_owner_id)
        for comment in comments
          unless comment.read_flag
            comment.read_flag = true
            comment.save
          end
        end
      end
    end
  end
end
