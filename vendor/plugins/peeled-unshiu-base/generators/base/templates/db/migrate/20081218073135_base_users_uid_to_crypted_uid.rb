class BaseUsersUidToCryptedUid < ActiveRecord::Migration
  def self.up
    rename_column :base_users, :uid, :crypted_uid
  end

  def self.down
    rename_column :base_users, :crypted_uid, :uid 
  end
end
