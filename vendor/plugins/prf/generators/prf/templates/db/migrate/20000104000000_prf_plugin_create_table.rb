class PrfPluginCreateTable < ActiveRecord::Migration
  
  def self.up
    create_table "prf_answers", :force => true do |t|
      t.column "prf_question_id", :integer,  :null => false
      t.column "prf_choice_id",   :integer,  :null => false
      t.column "prf_profile_id",  :integer,  :null => false
      t.column "body",            :text
      t.column "public_level",    :integer
      t.column "created_at",      :datetime
      t.column "updated_at",      :datetime
      t.column "deleted_at",      :datetime
    end

    create_table "prf_choices", :force => true do |t|
      t.column "prf_question_id", :integer,  :null => false
      t.column "prf_profile_id",  :integer,  :null => false
      t.column "body",            :text
      t.column "free_area_type",  :integer
      t.column "created_at",      :datetime
      t.column "updated_at",      :datetime
      t.column "deleted_at",      :datetime
    end

    create_table "prf_images", :force => true do |t|
      t.column "prf_profile_id", :integer,  :null => false
      t.column "image",          :string
      t.column "created_at",     :datetime
      t.column "updated_at",     :datetime
      t.column "deleted_at",     :datetime
    end

    create_table "prf_profiles", :force => true do |t|
      t.column "base_user_id", :integer,  :null => false
      t.column "created_at",   :datetime
      t.column "updated_at",   :datetime
      t.column "deleted_at",   :datetime
      t.column "prf_image_id", :integer
    end

    create_table "prf_question_set_partials", :force => true do |t|
      t.column "prf_question_set_id", :integer,  :null => false
      t.column "prf_question_id",     :integer,  :null => false
      t.column "order_num",           :integer
      t.column "required_flag",       :boolean
      t.column "created_at",          :datetime
      t.column "updated_at",          :datetime
      t.column "deleted_at",          :datetime
    end

    create_table "prf_question_sets", :force => true do |t|
      t.column "prf_profile_id", :integer,  :null => false
      t.column "name",           :string
      t.column "created_at",     :datetime
      t.column "updated_at",     :datetime
      t.column "deleted_at",     :datetime
    end

    create_table "prf_questions", :force => true do |t|
      t.column "prf_profile_id",   :integer,  :null => false
      t.column "question_type",    :integer
      t.column "body",             :text
      t.column "active_flag",      :boolean
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "deleted_at",       :datetime
      t.column "open_accept_type", :integer
    end
    
  end

  def self.down
    drop_table "prf_answers"
    drop_table "prf_choices"
    drop_table "prf_images"
    drop_table "prf_profiles"
    drop_table "prf_question_set_partials"
    drop_table "prf_question_sets"
    drop_table "prf_questions"
  end
end