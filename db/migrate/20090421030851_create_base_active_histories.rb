class CreateBaseActiveHistories < ActiveRecord::Migration
  def self.up
    create_table :base_active_histories do |t|
      t.date :history_day
      t.integer :before_days
      t.integer :user_count
      t.datetime :deleted_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :base_active_histories
  end
end
