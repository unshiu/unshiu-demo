# == Schema Information
#
# Table name: base_favorites
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  favorite_id  :integer(4)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

module BaseFavoriteModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :base_user
        belongs_to :favorite, :class_name => 'BaseUser', :foreign_key => 'favorite_id'
      end
    end
  end
  
  module ClassMethods
    # 気に入っている側の base_user_id と気に入られている側 base_user_id（favorite_id）と呼ぶから、BaseFavorite を探す
    def find_by_ids(base_user_id, favorite_id)
      return self.find(:first, :conditions => ["base_user_id = ? and favorite_id = ?", base_user_id, favorite_id])
    end
    
    # お気に入りを追加
    def add(base_user_id, favorite_id)
      if BaseFavorite.favorite?(base_user_id, favorite_id)
        return 'U-01004'
      end
      
      favorite = BaseFavorite.new
      favorite.base_user_id = base_user_id
      favorite.favorite_id = favorite_id
      favorite.save
    end
    
    # お気に入りか判定
    def favorite?(base_user_id, favorite_id)
      return find_by_ids(base_user_id, favorite_id) != nil
    end
  end
end
