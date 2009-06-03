class MsgPluginCreateTable < ActiveRecord::Migration
  def self.up
    create_table "msg_messages", :force => true do |t|
      t.column "title",             :string,   :default => "", :null => false
      t.column "body",              :text
      t.column "created_at",        :datetime
      t.column "updated_at",        :datetime
      t.column "deleted_at",        :datetime
      t.column "parent_message_id", :integer
    end

    create_table "msg_notifies", :force => true do |t|
      t.column "msg_message_id", :integer
      t.column "comment",        :text
      t.column "created_at",     :datetime
      t.column "updated_at",     :datetime
      t.column "deleted_at",     :datetime
    end

    create_table "msg_receivers", :force => true do |t|
      t.column "msg_message_id", :integer,                                  :null => false
      t.column "base_user_id",   :integer,                                  :null => false
      t.column "trash_status",   :integer,  :limit => 2
      t.column "replied_flag",   :boolean,               :default => false, :null => false
      t.column "read_flag",      :boolean,               :default => false, :null => false
      t.column "draft_flag",     :boolean
      t.column "created_at",     :datetime
      t.column "updated_at",     :datetime
      t.column "deleted_at",     :datetime
    end

    create_table "msg_senders", :force => true do |t|
      t.column "msg_message_id", :integer,                                  :null => false
      t.column "base_user_id",   :integer,                                  :null => false
      t.column "trash_status",   :integer,  :limit => 2
      t.column "draft_flag",     :boolean,               :default => false, :null => false
      t.column "created_at",     :datetime
      t.column "updated_at",     :datetime
      t.column "deleted_at",     :datetime
    end
    
  end

  def self.down
    drop_table "msg_messages"
    drop_table "msg_notifies"
    drop_table "msg_receivers"
    drop_table "msg_senders"
  end
end