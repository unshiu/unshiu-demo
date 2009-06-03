# == Schema Information
#
# Table name: prf_profiles
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#  prf_image_id :integer(4)
#  public_level :integer(4)      not null
#

class PrfProfile < ActiveRecord::Base
  include PrfProfileModule
end
