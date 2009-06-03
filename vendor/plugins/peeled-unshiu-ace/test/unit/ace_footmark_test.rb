require File.dirname(__FILE__) + '/../test_helper'

module AceFootmarkTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :ace_footmarks
      end
    end
  end
  
  define_method('test: 足跡は足跡の場所と自分と相手のIDから取得できる') do
    ace_footmark = AceFootmark.find_footmark("diary", 1, 2)
    assert_not_nil(ace_footmark)
    assert_equal(ace_footmark.count, 10)
  end
  
  define_method('test: 存在しない組み合わせを指定された場合は踏んだ数が0のレコードを作成してかえされる') do
    ace_footmark = AceFootmark.find_footmark("diary", 9999, 2)
    assert_not_nil(ace_footmark)
    assert_equal(ace_footmark.count, 0)
    
    after_ace_footmark = AceFootmark.find_by_place_and_base_user_id_and_footmarked_user_id("diary", 9999, 2)
    assert_not_nil(after_ace_footmark)
    assert_not_nil(after_ace_footmark.uuid)
  end
  
  define_method('test: find_footmark は既に作成済みだった場合レコードを作成することはしない') do
    ace_footmark = AceFootmark.find_footmark("diary#show", 1, 3)
    assert_not_nil(ace_footmark)
    assert_equal(ace_footmark.count, 0)
    
    ace_footmark = AceFootmark.find_footmark("diary#show", 1, 3)
    assert_not_nil(ace_footmark)
    assert_equal(ace_footmark.count, 0)
  end
  
end