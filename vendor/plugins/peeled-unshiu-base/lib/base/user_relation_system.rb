
module UserRelationSystem
  
  # 公開レベル
  PUBLIC_LEVEL_ALL    = 1
  PUBLIC_LEVEL_USER   = 2
  PUBLIC_LEVEL_FOAF   = 3
  PUBLIC_LEVEL_FRIEND = 4
  PUBLIC_LEVEL_ME     = 5

  PUBLIC_LEVELS = { "public_level_all"    => PUBLIC_LEVEL_ALL, 
                    "public_level_user"   => PUBLIC_LEVEL_USER, 
                    "public_level_friend" => PUBLIC_LEVEL_FRIEND, 
                    "public_level_foaf"   => PUBLIC_LEVEL_FOAF, 
                    "public_level_me"     => PUBLIC_LEVEL_ME } 
                    
  # 関係  上から優先
  USER_RELATION_EQUAL         = 1 # 同一ユーザー
  USER_RELATION_FRIEND        = 2 # 友だち
  USER_RELATION_FOAF          = 3 # 友だちの友だち
  USER_RELATION_LOGGED_IN     = 4 # ログインしているユーザー
  USER_RELATION_NOT_LOGGED_IN = 5 # ログインしていないユーザー

  module Acts # :nodoc:
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      # 公開レベルを必要とする　model に定義すると共通の関連定義がされる
      # また公開レベルごとの情報を取得するメソッドが追加される
      #
      # Examples ) 
      #   class Blog < ActiveRecord::Base
      #     acts_as_unshiu_user_relation
      #   end
      def acts_as_unshiu_user_relation
        levels = Hash.new
        UserRelationSystem::PUBLIC_LEVELS.each_pair do |key, value|
          levels[value] = I18n.t("activerecord.constant.user_relation_system.#{key}")
        end
        const_set('PUBLIC_LEVELS', levels)
        include InstanceMethods
      end
    end
    
    module InstanceMethods #:nodoc:
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end
      
      module ClassMethods
        # 全員へ公開するものを取得する
        # _param1_:: find系のoption
        def find_all_public(*args)
          options = args.extract_options!
          validate_find_options(options)
          options.merge!({:conditions => ["public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL]})
          find_every(options)
        end
        
        # レベル名称を返す
        def public_level_name(level)
          return I18n.t('activerecord.constant.user_relation_system.public_level_me') if level.nil? 
          UserRelationSystem::PUBLIC_LEVELS.each_pair do |key, value|
            if value == level
              return I18n.t("activerecord.constant.user_relation_system.#{key}")
            end 
          end
        end
        
      end
    end
  end
  
  def public_level_all?
    return public_level == PUBLIC_LEVEL_ALL
  end
  def public_level_user?
    return public_level == PUBLIC_LEVEL_USER
  end
  def public_level_foaf?
    return public_level == PUBLIC_LEVEL_FOAF
  end
  def public_level_friend?
    return public_level == PUBLIC_LEVEL_FRIEND
  end
  def public_level_none?
    return public_level == PUBLIC_LEVEL_NONE
  end
  
  # 指定したユーザー(base_user, owner_id)間の関係を返す
  def self.user_relation(base_user, other_base_user_id)
    if base_user != nil && base_user != :false && other_base_user_id != nil
      if base_user.me?(other_base_user_id)
        return USER_RELATION_EQUAL
      elsif base_user.friend?(other_base_user_id)
        return USER_RELATION_FRIEND
      elsif base_user.foaf?(other_base_user_id)
        return USER_RELATION_FOAF
      else
        return USER_RELATION_LOGGED_IN
      end
    else
      return USER_RELATION_NOT_LOGGED_IN
    end    
  end

  # 指定したユーザー(base_user, owner_id)間の関係と
  # 公開レベル(public_level)を比較してアクセス可能かを返す。
  # アクセス可能なら true, アクセス不可能なら false
  # 公開レベルが知らないものだったら問答無用で false
  def self.accessible?(base_user, owner_id, public_level)
    relation = user_relation(base_user, owner_id)
    case public_level
      when PUBLIC_LEVEL_ALL
        return true
      when PUBLIC_LEVEL_USER
        if relation == USER_RELATION_NOT_LOGGED_IN
          return false
        else
          return true
        end
      when PUBLIC_LEVEL_FOAF
        if relation == USER_RELATION_NOT_LOGGED_IN || relation == USER_RELATION_LOGGED_IN
          return false
        else
          return true
        end
      when PUBLIC_LEVEL_FRIEND
        if relation == USER_RELATION_FRIEND || relation == USER_RELATION_EQUAL
          return true
        else
          return false
        end
      when PUBLIC_LEVEL_ME
        if relation == USER_RELATION_EQUAL
          return true
        else
          return false
        end
      else
        return false
    end
  end

  # 友だちの友だちの間をつなぐを友だちの BaseUser を返す
  # 引き数のいずれかが nil なら nil が返る
  # 友だちの友だちでない場合は nil が返る
  # 複数いた場合は、base_users.id が一番若いユーザーが返る
  def self.find_friend_joined_foaf(base_user, foaf_id)
    if base_user && base_user != :false # means logged_in?
      if base_user.foaf?(foaf_id)
        BaseUser.find(:first,
          :joins => "LEFT OUTER JOIN base_friends base_friends1 ON base_friends1.friend_id = base_users.id LEFT OUTER JOIN base_friends base_friends2 ON base_friends2.base_user_id = base_users.id",
          :conditions => ["base_friends1.base_user_id = ? and base_friends2.friend_id = ?", base_user.id, foaf_id],
          :select => "base_users.*", :order => "base_users.id")
      else
        return nil
      end
    else
      return nil
    end
  end
  
protected

  # 指定したユーザー(base_user_id)と現在のユーザー(current_base_user)の関係を返す
  def user_relation(base_user_id)
    UserRelationSystem.user_relation(current_base_user, base_user_id)
  end
  
  # 指定したユーザー(owner_id)と現在のユーザー(current_base_user)の関係と
  # 公開レベル(public_level)を比較してアクセス可能かを返す。
  # _owner_id_:: 所有者の base_user_id
  # _public_level_:: 公開レベル
  # return:: アクセス可能なら true, アクセス不可能なら false.
  #          公開レベルが知らないものだったら問答無用で false
  def accessible?(owner_id, public_level)
    UserRelationSystem.accessible?(current_base_user, owner_id, public_level)
  end
  
end

ActiveRecord::Base.send :include, UserRelationSystem::Acts
