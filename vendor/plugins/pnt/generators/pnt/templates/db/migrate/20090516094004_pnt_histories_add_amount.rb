class PntHistoriesAddAmount < ActiveRecord::Migration
  def self.up
    add_column :pnt_histories, :amount,  :integer, :default => 0
  end

  def self.down
    remove_column :pnt_histories, :amount
  end
end
