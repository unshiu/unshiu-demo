class AcePluginCreateTable < ActiveRecord::Migration
  def self.up
    create_table "ace_access_logs", :force => true do |t|
      t.string   "host",          :limit => 32, :null => false
      t.string   "response_code", :limit => 8,  :null => false
      t.text     "request_url"
      t.text     "user_agent"
      t.integer  "base_user_id",                :null => false
      t.datetime "access_at",                   :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ace_access_logs", ["base_user_id"], :name => "index_ace_access_logs_on_base_user_id"
    add_index "ace_access_logs", ["access_at"], :name => "index_ace_access_logs_on_access_at"

    create_table "ace_footmarks", :force => true do |t|
      t.string   "base_user_id",                                     :null => false
      t.integer  "footmarked_user_id",                               :null => false
      t.string   "place",              :limit => 128,                :null => false
      t.string   "uuid",               :limit => 128,                :null => false
      t.integer  "count",                             :default => 0, :null => false
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ace_footmarks", ["uuid"], :name => "index_ace_footmarks_on_uuid", :unique => true
    add_index "ace_footmarks", ["base_user_id", "footmarked_user_id", "place"], :name => "ace_footmarks_unique_index", :unique => true

    create_table "ace_parse_logs", :force => true do |t|
      t.integer  "client_id",                     :null => false
      t.string   "filename",       :limit => 128, :null => false
      t.integer  "complate_point"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ace_parse_logs", ["client_id", "filename"], :name => "ace_parse_logs_unique_index", :unique => true
  end

  def self.down
    drop_table :ace_access_logs
    drop_table :ace_footmarks
    drop_table :ace_parse_logs
  end
end