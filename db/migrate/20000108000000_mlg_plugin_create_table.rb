class MlgPluginCreateTable < ActiveRecord::Migration
  
  def self.up
    create_table "mlg_deliveries", :force => true do |t|
      t.column "base_user_id",    :integer,  :null => false
      t.column "mlg_magazine_id", :integer,  :null => false
      t.column "sended_at",       :datetime
      t.column "created_at",      :datetime, :null => false
      t.column "updated_at",      :datetime, :null => false
      t.column "deleted_at",      :datetime
    end

    create_table "mlg_magazines", :force => true do |t|
      t.column "title",      :string,   :limit => 500,  :default => "", :null => false
      t.column "body",       :string,   :limit => 2000, :default => "", :null => false
      t.column "send_at",    :datetime
      t.column "sended_at",  :datetime
      t.column "created_at", :datetime,                                 :null => false
      t.column "updated_at", :datetime,                                 :null => false
      t.column "deleted_at", :datetime
    end
    
  end

  def self.down
    drop_table "mlg_deliveries"
    drop_table "mlg_magazines"
  end
end