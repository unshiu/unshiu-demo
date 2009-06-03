# == Schema Information
#
# Table name: tpc_topic_cmm_communities
#
#  id               :integer(4)      not null, primary key
#  tpc_topic_id     :integer(4)      not null
#  cmm_community_id :integer(4)      not null
#  public_level     :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#

class TpcTopicCmmCommunity < ActiveRecord::Base
  include TpcTopicCmmCommunityModule
end
