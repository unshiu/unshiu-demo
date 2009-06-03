# == Schema Information
#
# Table name: cmm_communities
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)     default(""), not null
#  profile            :text
#  image_file_name    :string(255)
#  join_type          :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#  deleted_at         :datetime
#  topic_create_level :integer(4)
#  cmm_image_id       :integer(4)
#

#= コミュニティを表すモデルクラス。
# コミュニティはトピックを複数持つ。
class CmmCommunity < ActiveRecord::Base
  include CmmCommunityModule
end
