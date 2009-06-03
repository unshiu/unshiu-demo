class TpcFixDeleterColumns < ActiveRecord::Migration
  def self.up
    add_column :tpc_comments, :invisibled_by, :integer
    remove_column :tpc_comments, :deleter
    remove_column :tpc_comments, :deleted_at
  end

  def self.down
    remove_column :tpc_comments, :invisibled_by
    add_column :tpc_comments, :deleter, :integer
    add_column :tpc_comments, :deleted_at, :datetime
  end
end
