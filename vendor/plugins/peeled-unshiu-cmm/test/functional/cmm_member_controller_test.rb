require File.dirname(__FILE__) + '/../test_helper'

module CmmMemberControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
      end
    end
  end
  
  define_method('test: コミュニティのメンバー一覧を閲覧する') do
    get :list, :id => 1
    
    community = assigns["community"]
    members = assigns["members"]
    
    assert_equal community, CmmCommunity.find_by_id(1)
    assert_instance_of PagingEnumerator, members
    assert_equal AppResources["cmm"]["member_list_size"], members.page_size
    members.each do |member|
      assert_instance_of CmmCommunitiesBaseUser, member
      assert CmmCommunitiesBaseUser::STATUSES_JOIN.include?(member.status)
    end
  end

end
