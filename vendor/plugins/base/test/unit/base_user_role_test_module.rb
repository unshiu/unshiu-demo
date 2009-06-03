require File.dirname(__FILE__) + '/../test_helper'

module BaseUserRoleTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_user_roles
        fixtures :base_users
      end
    end
  end

  def test_manager?
    # 管理者
    current_base_user = BaseUser.find(1)
    assert BaseUserRole.manager?(current_base_user)
    
    # 管理者じゃない人
    current_base_user = BaseUser.find(3)
    assert !BaseUserRole.manager?(current_base_user)
  end

  define_method('test: 指定ユーザを管理者として追加する') do 
    # 事前確認：権限がない
    assert_equal(BaseUser.find(3).base_user_roles.size, 0) 
    
    BaseUserRole.add_manager(3)
    
    base_user = BaseUser.find(3)
    base_user.base_user_roles.each do |role|
      assert_equal(role.role, 'manager') # 管理者ユーザとして追加する
    end
  end
  
  define_method('test: 指定ユーザが既に管理者だった場合は特に権限はかわらない') do 
    BaseUserRole.add_manager(1)
    
    base_user = BaseUser.find(1)
    assert_equal(base_user.base_user_roles.size, 1) # 権限レコードがふえるとかはない
    base_user.base_user_roles.each do |role|
      assert_equal(role.role, 'manager') # 管理者ユーザとして追加する
    end
  end
  
  def test_remove_manager
    # 管理者削除
    assert_not_nil BaseUserRole.remove_manager(1)
    
    # 管理者じゃない人
    assert_nil BaseUserRole.remove_manager(3)
    
  end

  define_method('test: 管理者の数を確認する') do 
    assert_equal 2, BaseUserRole.count_manager
  end
  
end