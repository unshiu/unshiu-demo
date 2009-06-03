# = acts_as_invisiable
# 
# == 概要
# modelのレコードを削除したいが、削除されたことを残したいようなmodelに利用する
#
# == 注意点
# 削除されているがレコードは残っているのでfind対象やカウント対象からはずしたいときは明示的に指定する必要がある。
#
# == 使い方
# 以下のように定義すると削除されているかどうかの判断メソッド等がつかえるようになる。
# 
# Comment < ActiveRecord::Base
#  acts_as_invisible
# end
#
# ブログとコメントの関係のような場合、コメントを消した場合、アルバムの持ち主が消したかどうかを判断するために関連先を設定する
#
# Comment < ActiveRecord::Base
#  acts_as_invisible :blog
# end
# 
# 関連は追っていくことが可能
#
# Comment < ActiveRecord::Base
#  acts_as_invisible :entry => :blog
# end
module ActiveRecord; module Acts; end; end 

module ActiveRecord::Acts::ActsAsInvisible
  
  def self.included(base)
    base.extend(ClassMethods)  
  end
  
  module ClassMethods
    
    def acts_as_invisible(owner_association_name = nil)
      cattr_accessor :owner_association_name
      send :include, InvisibleMethods
      
      self.owner_association_name = owner_association_name
    end
    
  end
  
  module InvisibleMethods
    
    # 削除者のIDを更新する
    # _param1_:: 削除者のユーザID
    def invisible_by(user_id)
      self.update_attribute(:invisibled_by, user_id)
    end
      
    # 削除を取り消す
    def cancel_invisibled
      self.update_attribute(:invisibled_by, nil)
    end
      
    # 誰かに削除されているかどうかを判断する
    # return:: 誰かに削除されていたらtrueが返る
    def invisibled_by_anyone?
      !not_invisibled_by_anyone?
    end
    
    # 誰かに削除されていないかどうかを判断する
    # return:: 誰かに削除されていなかったらtrueが返る
    def not_invisibled_by_anyone?
      self.invisibled_by.nil?
    end
    
    # 記載した人によって削除されているかどうかを判断する
    # return:: 削除者が記載した人ならtrueが返る
    def invisibled_by_writer?
      self.invisibled_by == self.base_user_id
    end
      
    # 持ち主（日記のコメントであれば日記の持ち主）によって削除されているかどうかを判断する
    # return:: 削除者が持ち主ならtrueが返る
    def invisibled_by_owner?
      return false unless owner_association_name
        owner_association = get_owner_association(self, owner_association_name)
      return false unless owner_association
      self.invisibled_by == owner_association.base_user_id
    end
      
    # システム運営者よって削除されているかどうかを判断する
    # return:: 削除者がシステム運営者ならtrueが返る
    def invisibled_by_manager?
      return false unless self.invisibled_by
      BaseUserRole.manager?(BaseUser.find(self.invisibled_by))
    end
    
    private
    
      def get_owner_association(object, name)
        if name.is_a?(Hash)
          next_object = object.send(name.keys[0])
          return get_owner_association(next_object, name.values[0])
        else
          return object.send(name)
        end
      end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::ActsAsInvisible)