class CmmPluginCreateTable < ActiveRecord::Migration
  def self.up
    create_table "cmm_communities", :force => true do |t|
      t.column "name",               :string,   :default => "", :null => false
      t.column "profile",            :text
      t.column "image_file_name",    :string
      t.column "join_type",          :integer
      t.column "created_at",         :datetime
      t.column "updated_at",         :datetime
      t.column "deleted_at",         :datetime
      t.column "topic_create_level", :integer
      t.column "cmm_image_id",       :integer
    end

    create_table "cmm_communities_base_users", :force => true do |t|
      t.column "cmm_community_id", :integer,  :null => false
      t.column "base_user_id",     :integer,  :null => false
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "deleted_at",       :datetime
      t.column "status",           :integer
    end

    create_table "cmm_community_flags", :force => true do |t|
      t.column "cmm_community_id", :integer,  :null => false
      t.column "flag_type",        :integer
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "deleted_at",       :datetime
    end

    create_table "cmm_community_tags", :force => true do |t|
      t.column "cmm_community_id", :integer,  :null => false
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "deleted_at",       :datetime
    end

    create_table "cmm_images", :force => true do |t|
      t.column "cmm_community_id", :integer,  :null => false
      t.column "image",            :string
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "deleted_at",       :datetime
    end

    create_table "cmm_tag_relations", :force => true do |t|
      t.column "cmm_tag_id",        :integer
      t.column "parent_cmm_tag_id", :integer
      t.column "created_at",        :datetime
      t.column "updated_at",        :datetime
      t.column "deleted_at",        :datetime
    end

    create_table "cmm_tags", :force => true do |t|
      t.column "name",       :string
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "deleted_at", :datetime
    end
    
  end

  def self.down
    drop_table "cmm_communities"
    drop_table "cmm_communities_base_users"
    drop_table "cmm_community_flags"
    drop_table "cmm_community_tags"
    drop_table "cmm_images"
    drop_table "cmm_tag_relations"
    drop_table "cmm_tags"
  end
end