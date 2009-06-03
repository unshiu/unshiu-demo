class BaseMailTemplateAddDevieceType < ActiveRecord::Migration
  def self.up
    add_column :base_mail_templates, :device_type, :integer, :null => false
  end

  def self.down
    remove_column :base_mail_templates, :device_type
  end
end
