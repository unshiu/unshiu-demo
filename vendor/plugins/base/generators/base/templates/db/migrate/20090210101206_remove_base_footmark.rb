class RemoveBaseFootmark < ActiveRecord::Migration
  def self.up
    drop_table "base_footmarks"
  end

  def self.down
    create_table "base_footmarks", :force => true do |t|
      t.column "base_user_id", :integer,  :null => false
      t.column "footmark_id",  :integer,  :null => false
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end
  end
end
