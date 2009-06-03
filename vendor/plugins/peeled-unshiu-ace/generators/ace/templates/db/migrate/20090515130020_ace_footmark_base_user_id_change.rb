class AceFootmarkBaseUserIdChange < ActiveRecord::Migration
  def self.up
    change_column(:ace_footmarks, :base_user_id, :integer)
  end

  def self.down
    change_column(:ace_footmarks, :base_user_id, :string)
  end
end
