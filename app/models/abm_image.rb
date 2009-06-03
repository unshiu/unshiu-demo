# == Schema Information
#
# Table name: abm_images
#
#  id                :integer(4)      not null, primary key
#  abm_album_id      :integer(4)      not null
#  title             :string(255)
#  body              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  image             :string(255)
#  image_size        :integer(4)      not null
#  original_filename :string(255)     not null
#  content_type      :string(255)     not null
#

class AbmImage < ActiveRecord::Base
  include AbmImageModule
end
