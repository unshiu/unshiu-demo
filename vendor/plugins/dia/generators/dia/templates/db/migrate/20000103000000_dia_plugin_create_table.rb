class DiaPluginCreateTable < ActiveRecord::Migration
  def self.up
    create_table "dia_diaries", :force => true do |t|
      t.column "base_user_id",         :integer,  :null => false
      t.column "default_public_level", :integer
      t.column "created_at",           :datetime
      t.column "updated_at",           :datetime
      t.column "deleted_at",           :datetime
    end

    create_table "dia_entries", :force => true do |t|
      t.column "dia_diary_id",      :integer,                     :null => false
      t.column "title",             :string,   :default => "",    :null => false
      t.column "body",              :text
      t.column "public_level",      :integer
      t.column "draft_flag",        :boolean,  :default => false, :null => false
      t.column "created_at",        :datetime
      t.column "updated_at",        :datetime
      t.column "deleted_at",        :datetime
      t.column "last_commented_at", :datetime
      t.column "contributed_at",    :datetime
    end

    create_table "dia_entries_abm_images", :force => true do |t|
      t.column "dia_entry_id", :integer,  :null => false
      t.column "abm_image_id", :integer,  :null => false
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
    end

    create_table "dia_entry_comments", :force => true do |t|
      t.column "base_user_id", :integer,                     :null => false
      t.column "dia_entry_id", :integer,                     :null => false
      t.column "body",         :text
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
      t.column "deleter",      :integer
      t.column "read_flag",    :boolean,  :default => false, :null => false
    end
    
  end

  def self.down
    drop_table "dia_diaries"
    drop_table "dia_entries"
    drop_table "dia_entries_abm_images"
    drop_table "dia_entry_comments"
  end
end