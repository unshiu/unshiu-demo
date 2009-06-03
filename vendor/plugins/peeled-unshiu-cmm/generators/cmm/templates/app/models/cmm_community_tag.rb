# == Schema Information
#
# Table name: cmm_community_tags
#
#  id               :integer(4)      not null, primary key
#  cmm_community_id :integer(4)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#

class CmmCommunityTag < ActiveRecord::Base
  include CmmCommunityTagModule
end
