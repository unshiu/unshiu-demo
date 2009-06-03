class AbmFixDeleterColumns < ActiveRecord::Migration
  def self.up
    add_column :abm_image_comments, :invisibled_by, :integer
    remove_column :abm_image_comments, :deleter
    remove_column :abm_image_comments, :deleted_at
  end

  def self.down
    remove_column :abm_image_comments, :invisibled_by, :integer
    add_column :abm_image_comments, :deleter, :integer
    add_column :abm_image_comments, :deleted_at, :datetime
  end
end
