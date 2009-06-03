require File.dirname(__FILE__) + '/../test_helper'

module CmmCommunitiesBaseUserTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :cmm_communities_base_users
        fixtures :cmm_communities
        fixtures :base_users
      end
    end
  end

  def test_relation
    ccbu = CmmCommunitiesBaseUser.find(1)
    assert_not_nil ccbu.cmm_community
    assert_not_nil ccbu.base_user
  end
  
  def test_find_joined_communities_by_user_id
    ret = CmmCommunitiesBaseUser.find_joined_communities_by_user_id(1)
    assert_equal 2, ret.size
    ret.each do |cu|
      assert_equal 1, cu.base_user_id
      assert_not_nil cu.status
      assert_not_equal CmmCommunitiesBaseUser::STATUS_REJECTED, cu.status
      assert_not_equal CmmCommunitiesBaseUser::STATUS_APPLYING, cu.status
    end
    
    # 参加拒否されているコミュニティがヒットしないことを確認
    ret = CmmCommunitiesBaseUser.find_joined_communities_by_user_id(6)
    assert_equal 1, ret.size
    ret.each do |cu|
      assert_equal 6, cu.base_user_id
      assert_not_nil cu.status
      assert_not_equal CmmCommunitiesBaseUser::STATUS_REJECTED, cu.status
    end
  end
  
  def test_find_applying_communities_by_user_id
    # 一件も申請中のコミュニティがない
    ret = CmmCommunitiesBaseUser.find_applying_communities_by_user_id(1)
    assert_equal 0, ret.size
    
    ret = CmmCommunitiesBaseUser.find_applying_communities_by_user_id(5)
    assert_equal 1, ret.size
    ret.each do |cu|
      assert_equal 5, cu.base_user_id
      assert_equal CmmCommunitiesBaseUser::STATUS_APPLYING, cu.status
    end
  end
  
  def test_find_rejected_communities_by_user_id
    ret = CmmCommunitiesBaseUser.find_rejected_communities_by_user_id(1)
    assert_equal 0, ret.size
    
    # 参加拒否されているものだけヒットすることを確認
    ret = CmmCommunitiesBaseUser.find_rejected_communities_by_user_id(6)
    assert_equal 1, ret.size
    ret.each do |cu|
      assert_equal 6, cu.base_user_id
      assert_equal CmmCommunitiesBaseUser::STATUS_REJECTED, cu.status
    end
  end
  
  def test_find_joined_by_community_id
    ret = CmmCommunitiesBaseUser.find_joined_by_community_id(1)
    assert_equal 4, ret.size
    ret.each do |cu|
      assert_equal 1, cu.cmm_community_id
      assert_not_equal CmmCommunitiesBaseUser::STATUS_REJECTED, cu.status
      assert_not_equal CmmCommunitiesBaseUser::STATUS_APPLYING, cu.status
    end
  end
  
  def test_admin?
    cu1 = CmmCommunitiesBaseUser.find(1)
    assert cu1.admin?
    
    cu3 = CmmCommunitiesBaseUser.find(3)
    assert !cu3.admin?
    
    cu4 = CmmCommunitiesBaseUser.find(4)
    assert !cu4.admin?

    cu5 = CmmCommunitiesBaseUser.find(5)
    assert !cu5.admin?
    
    cu6 = CmmCommunitiesBaseUser.find(6)
    assert !cu6.admin?
    
    cu7 = CmmCommunitiesBaseUser.find(7)
    assert !cu7.admin?
    
    cu8 = CmmCommunitiesBaseUser.find(8)
    assert !cu8.admin?
  end
  
  def test_subadmin?
    cu1 = CmmCommunitiesBaseUser.find(1)
    assert !cu1.subadmin?
    
    cu3 = CmmCommunitiesBaseUser.find(3)
    assert cu3.subadmin?
    
    cu4 = CmmCommunitiesBaseUser.find(4)
    assert !cu4.subadmin?

    cu5 = CmmCommunitiesBaseUser.find(5)
    assert !cu5.subadmin?
    
    cu6 = CmmCommunitiesBaseUser.find(6)
    assert !cu6.subadmin?
    
    cu7 = CmmCommunitiesBaseUser.find(7)
    assert !cu7.subadmin?
    
    cu8 = CmmCommunitiesBaseUser.find(8)
    assert !cu8.subadmin?
  end
  
  def test_member?
    cu1 = CmmCommunitiesBaseUser.find(1)
    assert !cu1.member?
    
    cu3 = CmmCommunitiesBaseUser.find(3)
    assert !cu3.member?
    
    cu4 = CmmCommunitiesBaseUser.find(4)
    assert !cu4.member?

    cu5 = CmmCommunitiesBaseUser.find(5)
    assert !cu5.member?
    
    cu6 = CmmCommunitiesBaseUser.find(6)
    assert !cu6.member?
    
    cu7 = CmmCommunitiesBaseUser.find(7)
    assert cu7.member?
    
    cu8 = CmmCommunitiesBaseUser.find(8)
    assert !cu8.member?
  end
  
  def test_guest?
    cu1 = CmmCommunitiesBaseUser.find(1)
    assert !cu1.guest?
    
    cu3 = CmmCommunitiesBaseUser.find(3)
    assert !cu3.guest?
    
    cu4 = CmmCommunitiesBaseUser.find(4)
    assert cu4.guest?

    cu5 = CmmCommunitiesBaseUser.find(5)
    assert !cu5.guest?
    
    cu6 = CmmCommunitiesBaseUser.find(6)
    assert !cu6.guest?
    
    cu7 = CmmCommunitiesBaseUser.find(7)
    assert !cu7.guest?
    
    cu8 = CmmCommunitiesBaseUser.find(8)
    assert !cu8.guest?
  end
  
  def test_applying?
    cu1 = CmmCommunitiesBaseUser.find(1)
    assert !cu1.applying?

    cu3 = CmmCommunitiesBaseUser.find(3)
    assert !cu3.applying?
    
    cu4 = CmmCommunitiesBaseUser.find(4)
    assert !cu4.applying?

    cu6 = CmmCommunitiesBaseUser.find(5)
    assert cu6.applying?
    
    cu6 = CmmCommunitiesBaseUser.find(6)
    assert !cu6.applying?
    
    cu7 = CmmCommunitiesBaseUser.find(7)
    assert !cu7.applying?

    cu8 = CmmCommunitiesBaseUser.find(8)
    assert !cu8.applying?
  end
  
  def test_rejected?
    cu1 = CmmCommunitiesBaseUser.find(1)
    assert !cu1.rejected?

    cu3 = CmmCommunitiesBaseUser.find(3)
    assert !cu3.rejected?
    
    cu4 = CmmCommunitiesBaseUser.find(4)
    assert !cu4.rejected?

    cu5 = CmmCommunitiesBaseUser.find(5)
    assert !cu5.rejected?
    
    cu6 = CmmCommunitiesBaseUser.find(6)
    assert cu6.rejected?
    
    cu7 = CmmCommunitiesBaseUser.find(7)
    assert !cu7.rejected?

    cu8 = CmmCommunitiesBaseUser.find(8)
    assert !cu8.rejected?
  end
  
  define_method('test: 最近登録したメンバーを取得する') do
    cmm_community = CmmCommunity.find(1)
    assert_not_nil(cmm_community.cmm_communities_base_users)
    assert_not_nil(cmm_community.cmm_communities_base_users.recent_join(5))
    
    assert_not_equal(cmm_community.cmm_communities_base_users.recent_join(5).length, 0)
    assert_equal(cmm_community.cmm_communities_base_users.recent_join(1).length, 1) # 最大が1なら1つしか取得しない
  end
  
  define_method('test: メンバーステータス名を取得する') do
    user = CmmCommunitiesBaseUser.new
    user.status = 0
    assert_equal(user.status_name, "")
    
    user.status = 1
    assert_equal(user.status_name, "管理者")
    
    user.status = 50
    assert_equal(user.status_name, "参加申請中")
  end
  
end
