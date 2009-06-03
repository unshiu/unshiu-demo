# == Schema Information
#
# Table name: abm_albums
#
#  id                 :integer(4)      not null, primary key
#  base_user_id       :integer(4)      not null
#  title              :string(255)
#  body               :text
#  created_at         :datetime
#  updated_at         :datetime
#  deleted_at         :datetime
#  public_level       :integer(4)
#  cover_abm_image_id :integer(4)
#

class AbmAlbum < ActiveRecord::Base
  include AbmAlbumModule
end
