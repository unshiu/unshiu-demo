class CreateMngUserActionHistories < ActiveRecord::Migration
  def self.up
    create_table :mng_user_action_histories do |t|
      t.integer  :base_user_id, :null => false
      t.text     :user_action,  :null => false
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :mng_user_action_histories
  end
end
