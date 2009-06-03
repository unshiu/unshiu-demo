require File.dirname(__FILE__) + '/../test_helper'

module BaseActiveHistoryTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :base_users
        fixtures :base_active_histories
      end
    end
  end
  
  define_method('test: ３日前をアクティブとするユーザ履歴を取得する') do
    base_active_histories = BaseActiveHistory.before(3)
    
    base_active_histories.each do |base_active_history|
      assert_equal(base_active_history.before_day, 3)
    end
  end
end
