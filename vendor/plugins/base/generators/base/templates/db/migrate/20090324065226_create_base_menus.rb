class CreateBaseMenus < ActiveRecord::Migration
  def self.up
    create_table :base_menus do |t|
      t.integer  :base_user_id,        :null => false
      t.integer  :base_menu_master_id, :null => false
      t.integer  :num,                 :null => false
      t.boolean  :show_flag,           :null => false,  :default => true
      t.datetime :deleted_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :base_menus
  end
end
