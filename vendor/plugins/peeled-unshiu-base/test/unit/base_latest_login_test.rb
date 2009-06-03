require File.dirname(__FILE__) + '/../test_helper'

module BaseLatestLoginTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :base_users
      end
    end
  end
  
  define_method('test: 最終ログイン日を更新する') do
    base_latest_login = BaseLatestLogin.update_latest_login(1)
    
    assert_not_nil(base_latest_login.latest_login) # 最終日付がある
  end
  
  define_method('test: キャッシュされた最終ログイン日を取得する') do
    base_latest_login = BaseLatestLogin.find_by_base_user_id(1)
    assert_not_nil(base_latest_login.latest_login) # 最終日付がある
  end
  
  define_method('test: 最終ログイン日がない場合はnilオブジェクトがかえる') do
    base_latest_login = BaseLatestLogin.find_by_base_user_id(999)
    assert_nil(base_latest_login)
  end
  
end