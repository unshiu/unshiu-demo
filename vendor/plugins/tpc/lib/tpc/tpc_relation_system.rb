
module TpcRelationSystem
  
  # 公開レベル
  PUBLIC_LEVEL_ALL          = 1
  PUBLIC_LEVEL_USER         = 2
  PUBLIC_LEVEL_PARTICIPANT  = 3 # コミュニティ関係者のみ
  
  PUBLIC_LEVELS = { "public_level_all"         => PUBLIC_LEVEL_ALL, 
                    "public_level_user"        => PUBLIC_LEVEL_USER, 
                    "public_level_participant" => PUBLIC_LEVEL_PARTICIPANT } 

  module Acts # :nodoc:
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      # 公開レベルを必要とする　model に定義するとTpc共通の関連定義がされる
      # また公開レベルごとの情報を取得するメソッドが追加される
      #
      # Examples ) 
      #   class Blog < ActiveRecord::Base
      #     acts_as_unshiu_user_relation
      #   end
      def acts_as_unshiu_tpc_relation
        levels = Hash.new
        TpcRelationSystem::PUBLIC_LEVELS.each_pair do |key, value|
          levels[value] = I18n.t("activerecord.constant.tpc_relation_system.#{key}")
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
        
        # レベル名称を返す
        def public_level_name(level)
          TpcRelationSystem::PUBLIC_LEVELS.each_pair do |key, value|
            if value == level
              return I18n.t("activerecord.constant.tpc_relation_system.#{key}")
            end 
          end
        end
        
        def public_level_all?
          public_level == PUBLIC_LEVEL_ALL
        end

        def public_level_user?
          public_level == PUBLIC_LEVEL_USER
        end

        def public_level_participant?
          public_level == PUBLIC_LEVEL_PARTICIPANT
        end
        
      end
    end
  end
  
end

ActiveRecord::Base.send :include, TpcRelationSystem::Acts
