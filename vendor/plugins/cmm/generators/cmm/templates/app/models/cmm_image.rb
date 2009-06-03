# == Schema Information
#
# Table name: cmm_images
#
#  id               :integer(4)      not null, primary key
#  cmm_community_id :integer(4)      not null
#  image            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#

class CmmImage < ActiveRecord::Base
  include CmmImageModule
end
