class DiaFixDeleterColumns < ActiveRecord::Migration
  def self.up
    add_column :dia_entry_comments, :invisibled_by, :integer
    remove_column :dia_entry_comments, :deleter
    remove_column :dia_entry_comments, :deleted_at
  end

  def self.down
    remove_column :dia_entry_comments, :invisibled_by
    add_column :dia_entry_comments, :deleter, :integer
    add_column :dia_entry_comments, :deleted_at, :datetime
  end
end
