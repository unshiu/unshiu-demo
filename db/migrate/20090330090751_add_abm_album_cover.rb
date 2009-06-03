class AddAbmAlbumCover < ActiveRecord::Migration
  def self.up
    add_column :abm_albums, :cover_abm_image_id,  :integer
  end

  def self.down
    remove_column :abm_albums, :cover_abm_image_id
  end
end
