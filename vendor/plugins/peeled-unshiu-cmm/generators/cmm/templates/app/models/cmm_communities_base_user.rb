# == Schema Information
#
# Table name: cmm_communities_base_users
#
#  id               :integer(4)      not null, primary key
#  cmm_community_id :integer(4)      not null
#  base_user_id     :integer(4)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#  status           :integer(4)
#

class CmmCommunitiesBaseUser < ActiveRecord::Base
  include CmmCommunitiesBaseUserModule
end
