class CreateBaseUserFileHistory < ActiveRecord::Migration
  def self.up
    create_table :base_user_file_histories do |t|
      t.column :base_user_id,     :integer, :null => false 
      t.column :file_name,        :string,  :null => false
      t.column :complated_at,     :datetime
      t.column :deleted_at,       :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :base_user_file_histories
  end
end
