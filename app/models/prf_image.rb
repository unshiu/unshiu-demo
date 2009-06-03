# == Schema Information
#
# Table name: prf_images
#
#  id             :integer(4)      not null, primary key
#  prf_profile_id :integer(4)      not null
#  image          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

class PrfImage < ActiveRecord::Base
  include PrfImageModule
end
