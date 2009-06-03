require File.dirname(__FILE__) + '/../../test_helper'

class BaseProfile < ActiveRecord::Base
  include BaseProfileModule
  acts_as_unshiu_user_relation
end

module UserRelationSystemTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_friends
      end
    end
  end
  
  define_method('test: 関連レベル名称を取得する') do 
    profile = BaseProfile.new
    assert_equal BaseProfile.public_level_name(1), "全員に公開"
  end
  
  define_method('test: 関連レベルにnilを渡された場合自分だけ公開と見なす') do 
    profile = BaseProfile.new
    assert_equal BaseProfile.public_level_name(nil), "自分にだけ公開"
  end
  
  define_method('test: accessible? は公開レベルから判別してアクセス可能かを返す') do 
    # 友達同士
    user = BaseUser.find(1)
    friend = BaseUser.find(2)
    assert_equal(UserRelationSystem.user_relation(user, 2), UserRelationSystem::USER_RELATION_FRIEND) # id = 1 と 2は友達
    
    assert_equal(UserRelationSystem.accessible?(user, 2, UserRelationSystem::PUBLIC_LEVEL_ALL), true)     # 全員公開はみれる
    assert_equal(UserRelationSystem.accessible?(user, 2, UserRelationSystem::PUBLIC_LEVEL_USER), true)    # ユーザ公開はみれる
    assert_equal(UserRelationSystem.accessible?(user, 2, UserRelationSystem::PUBLIC_LEVEL_FRIEND), true) # 友達まで公開はみれる
    assert_equal(UserRelationSystem.accessible?(user, 2, UserRelationSystem::PUBLIC_LEVEL_FOAF), true)    # 友達の友達まで公開はみれる
    assert_equal(UserRelationSystem.accessible?(user, 2, UserRelationSystem::PUBLIC_LEVEL_ME), false)     # 自分のみ公開はみれない
    
    # 友達の友達
    assert_equal(UserRelationSystem.user_relation(user, 4), UserRelationSystem::USER_RELATION_FOAF) # id = 1 と 4は友達の友達
    
    assert_equal(UserRelationSystem.accessible?(user, 4, UserRelationSystem::PUBLIC_LEVEL_ALL), true)     # 全員公開はみれる
    assert_equal(UserRelationSystem.accessible?(user, 4, UserRelationSystem::PUBLIC_LEVEL_USER), true)    # ユーザ公開はみれる
    assert_equal(UserRelationSystem.accessible?(user, 4, UserRelationSystem::PUBLIC_LEVEL_FRIEND), false) # 友達まで公開はみれない
    assert_equal(UserRelationSystem.accessible?(user, 4, UserRelationSystem::PUBLIC_LEVEL_FOAF), true)    # 友達の友達まで公開はみれる
    assert_equal(UserRelationSystem.accessible?(user, 4, UserRelationSystem::PUBLIC_LEVEL_ME), false)     # 自分のみ公開はみれない
  end
  
end