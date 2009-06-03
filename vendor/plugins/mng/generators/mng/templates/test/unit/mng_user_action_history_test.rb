require File.dirname(__FILE__) + '/../test_helper'

class MngUserActionHistoryTest < ActiveSupport::TestCase
  
  fixtures :base_users
  fixtures :base_user_roles
  fixtures :mng_user_action_histories
  
  define_method('test: 各テーブルと関連を持つ') do
    mng_user_action_history = MngUserActionHistory.find(1)
    
    assert_not_nil(mng_user_action_history)
    assert_not_nil(mng_user_action_history.base_user)
  end
  
end
