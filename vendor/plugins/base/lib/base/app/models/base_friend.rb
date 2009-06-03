# == Schema Information
#
# Table name: base_friends
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  friend_id    :integer(4)      not null
#  status       :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

module BaseFriendModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :base_user
        belongs_to :friend, :class_name => 'BaseUser', :foreign_key => 'friend_id'
        
        const_set('STATUS_FRIEND', 1)
        const_set('STATUS_APPLYING', 2)
        
      end
    end
  end
  
  module ClassMethods
    # 友だち（base_tables, 申請中を含む）を探す
    # 該当ID が存在しない場合は nil
    def find_friend(base_user_id, friend_id)
      return self.find(:first, :conditions => ["base_user_id = ? and friend_id = ?", base_user_id, friend_id])
    end
    
    # 指定したパラメータで友だち関係を追加する（一方通行）
    # すでに友だち関係がある場合（申請中を含む）はエラーになる
    # return:: 新たに追加した BaseFriend，もしくはエラーメッセージ String
    def add(base_user_id, friend_id, status = BaseFriend::STATUS_FRIEND)
      if BaseFriend.friend_or_applying?(base_user_id, friend_id)
        return 'U-01010'
      elsif BaseUser.find_by_id(base_user_id) == nil || BaseUser.find_by_id(friend_id) == nil
        return 'U-01011'
      end
      
      friend = BaseFriend.new
      friend.base_user_id = base_user_id
      friend.friend_id = friend_id
      friend.status = status
      friend.save
      friend
    end
    
    # 友達なら true
    def friend?(base_user_id, friend_id)
      return BaseFriend.find(:first, :conditions => ["base_user_id = ? and friend_id = ? and status = ?", base_user_id, friend_id, BaseFriend::STATUS_FRIEND]) != nil
    end
    
    # 友達か申請中なら true
    def friend_or_applying?(base_user_id, friend_id)
      return BaseFriend.find(:first, :conditions => ["base_user_id = ? and friend_id = ?", base_user_id, friend_id]) != nil
    end
  end
  
  # 自身の base_user_id と friend_id を逆にしたものを探す
  # 申請中だと見つからないので nil
  def find_reverse
    return BaseFriend.find(:first, :conditions => ["base_user_id = ? and friend_id = ?", friend_id, base_user_id])
  end
  
  # 申請中なら true
  def applying?
    self.status == BaseFriend::STATUS_APPLYING
  end
  
  # 友達承認
  def permit
    self.status = BaseFriend::STATUS_FRIEND
    self.save
    
    BaseFriend.add(friend_id, base_user_id)
  end
  
  # 友だち拒否
  def deny
    self.destroy
  end
end
