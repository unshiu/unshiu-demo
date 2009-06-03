class TpcTopicAddCommentCount < ActiveRecord::Migration
  def self.up
    add_column :tpc_topics, :comment_count,  :integer, :default => 0
  end

  def self.down
    remove_column :tpc_topics, :comment_count
  end
end
