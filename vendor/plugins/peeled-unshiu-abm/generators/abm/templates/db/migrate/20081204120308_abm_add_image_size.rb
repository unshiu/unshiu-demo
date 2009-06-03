class AbmAddImageSize < ActiveRecord::Migration
  def self.up
    add_column :abm_images, :image_size,        :integer, :null => false
    add_column :abm_images, :original_filename, :string, :null => false
    add_column :abm_images, :content_type,      :string, :null => false
  end

  def self.down
    remove_column :abm_images, :image_size
    remove_column :abm_images, :original_filename
    remove_column :abm_images, :content_type
  end
end
