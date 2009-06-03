class TpcPluginCreateTable < ActiveRecord::Migration
  
  def self.up
    create_table "tpc_comment_abm_images", :force => true do |t|
      t.column "tpc_comment_id", :integer,  :null => false
      t.column "abm_image_id",   :integer,  :null => false
      t.column "created_at",     :datetime
      t.column "updated_at",     :datetime
      t.column "deleted_at",     :datetime
    end

    create_table "tpc_comments", :force => true do |t|
      t.column "title",        :string
      t.column "body",         :text
      t.column "tpc_topic_id", :integer,  :null => false
      t.column "base_user_id", :integer,  :null => false
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
      t.column "deleter",      :integer
    end

    create_table "tpc_topic_abm_images", :force => true do |t|
      t.column "tpc_topic_id", :integer,  :null => false
      t.column "abm_image_id", :integer,  :null => false
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end

    create_table "tpc_topic_cmm_communities", :force => true do |t|
      t.column "tpc_topic_id",     :integer,  :null => false
      t.column "cmm_community_id", :integer,  :null => false
      t.column "public_level",     :integer
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "deleted_at",       :datetime
    end

    create_table "tpc_topics", :force => true do |t|
      t.column "title",             :string
      t.column "body",              :text
      t.column "base_user_id",      :integer,  :null => false
      t.column "created_at",        :datetime
      t.column "updated_at",        :datetime
      t.column "deleted_at",        :datetime
      t.column "last_commented_at", :datetime
    end
    
  end

  def self.down
    drop_table "tpc_comment_abm_images"
    drop_table "tpc_comments"
    drop_table "tpc_topic_abm_images"
    drop_table "tpc_topic_cmm_communities"
    drop_table "tpc_topics"
  end
end