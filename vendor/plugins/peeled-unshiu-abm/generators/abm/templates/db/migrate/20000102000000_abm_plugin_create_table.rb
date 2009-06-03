class AbmPluginCreateTable < ActiveRecord::Migration
  def self.up
    create_table "abm_albums", :force => true do |t|
      t.column "base_user_id", :integer,  :null => false
      t.column "title",        :string
      t.column "body",         :text
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
      t.column "public_level", :integer
    end

    create_table "abm_image_comments", :force => true do |t|
      t.column "base_user_id", :integer,  :null => false
      t.column "abm_image_id", :integer,  :null => false
      t.column "body",         :text
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
      t.column "deleter",      :integer
    end

    create_table "abm_images", :force => true do |t|
      t.column "abm_album_id", :integer,  :null => false
      t.column "title",        :string
      t.column "body",         :string
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
      t.column "image",        :string
    end
  end

  def self.down
    drop_table "abm_albums"
    drop_table "abm_image_comments"
    drop_table "abm_images"
  end
end