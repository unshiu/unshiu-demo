

class TpcTopicCmmCommunity < ActiveRecord::Base
  include TpcTopicCmmCommunityModule
  acts_as_unshiu_tpc_relation
end

module TpcRelationSystemTestModule

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
    profile = TpcTopicCmmCommunity.new
    assert_equal TpcTopicCmmCommunity.public_level_name(1), "全員に公開"
  end
  
end