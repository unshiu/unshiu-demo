class PntPluginCreateTable < ActiveRecord::Migration
  def self.up
    create_table "pnt_file_update_histories", :force => true do |t|
      t.column "file_name",     :string,   :limit => 256, :default => "", :null => false
      t.column "record_count",  :integer
      t.column "success_count", :integer
      t.column "fail_count",    :integer
      t.column "complated_at",  :datetime
      t.column "created_at",    :datetime,                                :null => false
      t.column "updated_at",    :datetime,                                :null => false
      t.column "deleted_at",    :datetime
    end

    create_table "pnt_filter_masters", :force => true do |t|
      t.column "title",           :string,   :limit => 500, :default => "", :null => false
      t.column "controller_name", :string,   :limit => 256, :default => "", :null => false
      t.column "action_name",     :string,   :limit => 256, :default => "", :null => false
      t.column "created_at",      :datetime,                                :null => false
      t.column "updated_at",      :datetime,                                :null => false
      t.column "deleted_at",      :datetime
    end

    create_table "pnt_filters", :force => true do |t|
      t.column "pnt_master_id",        :integer,                 :null => false
      t.column "point",                :integer,                 :null => false
      t.column "created_at",           :datetime,                :null => false
      t.column "updated_at",           :datetime,                :null => false
      t.column "deleted_at",           :datetime
      t.column "summary",              :string,   :limit => 200
      t.column "pnt_filter_master_id", :integer,                 :null => false
      t.column "start_at",             :datetime
      t.column "end_at",               :datetime
      t.column "rule_day",             :integer
      t.column "rule_count",           :integer
      t.column "stock",                :integer
    end

    create_table "pnt_histories", :force => true do |t|
      t.column "pnt_point_id",  :integer,                                  :null => false
      t.column "difference",    :integer,                  :default => 0,  :null => false
      t.column "created_at",    :datetime
      t.column "updated_at",    :datetime
      t.column "deleted_at",    :datetime
      t.column "message",       :string,   :limit => 2000, :default => "", :null => false
      t.column "pnt_filter_id", :integer
    end

    create_table "pnt_history_summaries", :force => true do |t|
      t.column "start_at",        :datetime,                                :null => false
      t.column "end_at",          :datetime,                                :null => false
      t.column "sum_issue_point", :integer,                                 :null => false
      t.column "sum_use_point",   :integer,                                 :null => false
      t.column "record_count",    :integer,                                 :null => false
      t.column "file_name",       :string,   :limit => 256, :default => "", :null => false
      t.column "created_at",      :datetime
      t.column "updated_at",      :datetime
      t.column "deleted_at",      :datetime
      t.column "kind_type",       :integer,                                 :null => false
    end

    create_table "pnt_masters", :force => true do |t|
      t.column "title",      :string,   :limit => 200, :default => "", :null => false
      t.column "created_at", :datetime,                                :null => false
      t.column "updated_at", :datetime,                                :null => false
      t.column "deleted_at", :datetime
    end

    create_table "pnt_points", :force => true do |t|
      t.column "base_user_id",  :integer,                 :null => false
      t.column "point",         :integer,  :default => 0, :null => false
      t.column "created_at",    :datetime
      t.column "updated_at",    :datetime
      t.column "deleted_at",    :datetime
      t.column "pnt_master_id", :integer,                 :null => false
    end

    create_table "pnt_update_error_records", :force => true do |t|
      t.column "pnt_file_update_hisotry_id", :integer,                                  :null => false
      t.column "line_number",                :integer,                                  :null => false
      t.column "record",                     :string,                   :default => "", :null => false
      t.column "reason",                     :string,   :limit => 1000, :default => "", :null => false
      t.column "created_at",                 :datetime,                                 :null => false
      t.column "updated_at",                 :datetime,                                 :null => false
      t.column "deleted_at",                 :datetime
    end
    
  end

  def self.down
    drop_table "pnt_file_update_histories"
    drop_table "pnt_filter_masters"
    drop_table "pnt_filters"
    drop_table "pnt_histories"
    drop_table "pnt_history_summaries"
    drop_table "pnt_masters"
    drop_table "pnt_points"
    drop_table "pnt_update_error_records"
  end
end