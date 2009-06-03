class CreateMngUserActionHistoryArchives < ActiveRecord::Migration
  def self.up
    create_table :mng_user_action_history_archives do |t|
      t.string   :filename,       :null => false
      t.integer  :filesize,       :null => false
      t.datetime :start_datetime, :null => false
      t.datetime :end_datetime,   :null => false
      t.datetime :deleted_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mng_user_action_history_archives
  end
end
