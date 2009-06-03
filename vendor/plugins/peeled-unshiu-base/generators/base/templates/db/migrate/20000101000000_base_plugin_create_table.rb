class BasePluginCreateTable < ActiveRecord::Migration
  def self.up

    create_table "base_carriers", :force => true do |t|
      t.column "name",       :string,   :limit => 256, :default => "", :null => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "deleted_at", :datetime
    end

    create_table "base_favorites", :force => true do |t|
      t.column "base_user_id", :integer,  :null => false
      t.column "favorite_id",  :integer,  :null => false
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end

    create_table "base_footmarks", :force => true do |t|
      t.column "base_user_id", :integer,  :null => false
      t.column "footmark_id",  :integer,  :null => false
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end

    create_table "base_friends", :force => true do |t|
      t.column "base_user_id", :integer,  :null => false
      t.column "friend_id",    :integer,  :null => false
      t.column "status",       :integer
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end

    create_table "base_inquires", :force => true do |t|
      t.column "title",        :string
      t.column "body",         :text
      t.column "referer",      :string
      t.column "mail_address", :string
      t.column "base_user_id", :integer
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end

    create_table "base_mail_dispatch_infos", :force => true do |t|
      t.column "mail_address", :string
      t.column "model_name",   :string
      t.column "method_name",  :string
      t.column "model_id",     :integer
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
      t.column "base_user_id", :integer
    end

    create_table "base_ng_words", :force => true do |t|
      t.column "word",        :string
      t.column "active_flag", :boolean
      t.column "created_at",  :datetime
      t.column "updated_at",  :datetime
      t.column "deleted_at",  :datetime
    end

    create_table "base_notices", :force => true do |t|
      t.column "title",          :string
      t.column "body",           :text
      t.column "start_datetime", :datetime
      t.column "end_datetime",   :datetime
      t.column "created_at",     :datetime
      t.column "updated_at",     :datetime
      t.column "deleted_at",     :datetime
    end

    create_table "base_profiles", :force => true do |t|
      t.column "base_user_id",              :integer,                 :null => false
      t.column "name",                      :string,   :limit => 100
      t.column "name_public_level",         :integer
      t.column "kana_name",                 :string,   :limit => 100
      t.column "kana_name_public_level",    :integer
      t.column "introduction",              :text
      t.column "introduction_public_level", :integer
      t.column "sex",                       :integer
      t.column "sex_public_level",          :integer
      t.column "civil_status",              :integer
      t.column "civil_status_public_level", :integer
      t.column "birthday",                  :date
      t.column "birthday_public_level",     :integer
      t.column "created_at",                :datetime
      t.column "updated_at",                :datetime
      t.column "deleted_at",                :datetime
      t.column "image",                     :string
      t.column "area",                      :string
      t.column "area_public_level",         :integer
    end
    add_index "base_profiles", ["base_user_id"], :name => "index_base_profiles_on_base_user_id"
    
    create_table "base_user_roles", :force => true do |t|
      t.column "base_user_id", :integer
      t.column "role",         :string
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end
    add_index "base_user_roles", ["base_user_id"], :name => "index_base_user_roles_on_base_user_id"
    
    create_table "base_users", :force => true do |t|
      t.column "login",                      :string
      t.column "email",                      :string
      t.column "crypted_password",           :string,   :limit => 40
      t.column "salt",                       :string,   :limit => 40
      t.column "created_at",                 :datetime
      t.column "updated_at",                 :datetime
      t.column "remember_token",             :string
      t.column "remember_token_expires_at",  :datetime
      t.column "deleted_at",                 :datetime
      t.column "status",                     :integer
      t.column "activation_code",            :string
      t.column "uid",                        :string
      t.column "joined_at",                  :datetime
      t.column "quitted_at",                 :datetime
      t.column "new_email",                  :string
      t.column "receive_system_mail_flag",   :boolean
      t.column "receive_mail_magazine_flag", :boolean
      t.column "message_accept_level",       :integer,                :default => 2,    :null => false
      t.column "footmark_flag",              :boolean,                :default => true, :null => false
      t.column "base_carrier_id",            :integer
      t.column "device_name",                :string
      t.column "name",                       :string
    end
    add_index "base_users", ["status"], :name => "index_base_users_on_status"
    add_index "base_users", ["email"], :name => "index_base_users_on_email"
    add_index "base_users", ["activation_code"], :name => "index_base_users_on_activation_code"
    add_index "base_users", ["uid"], :name => "index_base_users_on_uid"
    add_index "base_users", ["joined_at"], :name => "index_base_users_on_joined_at"
    
    create_table :base_errors, :force => true do |t|
      t.column :error_code, :string, :null => false 
      t.column :message,    :text,   :null => false
      t.column :coping,     :text,   :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
  end

  def self.down
    drop_table "base_carriers"
    drop_table "base_favorites"
    drop_table "base_footmarks"
    drop_table "base_friends"
    drop_table "base_inquires"
    drop_table "base_mail_dispatch_infos"
    drop_table "base_ng_words"
    drop_table "base_notices"
    drop_table "base_profiles"
    drop_table "base_user_roles"
    drop_table "base_users"
    drop_table :base_errors
  end
end