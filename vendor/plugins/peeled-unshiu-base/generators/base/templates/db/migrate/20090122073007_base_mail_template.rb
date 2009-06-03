class BaseMailTemplate < ActiveRecord::Migration
  def self.up
    create_table :base_mail_templates do |t|
      t.column :base_mail_template_kind_id, :integer, :null => false 
      t.column :content_type,               :string, :null => false 
      t.column :subject,                    :string, :null => false 
      t.column :body,                       :text,   :null => false
      t.column :active_flag,      :boolean
      t.column :footer_flag,      :boolean
      t.column :deleted_at,       :datetime
      t.timestamps
    end
    
    create_table :base_mail_template_kinds do |t|
      t.column :action,             :string, :null => false 
      t.column :name,               :string, :null => false 
      t.column :description,        :string, :null => false 
      t.column :deleted_at,       :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :base_mail_templates
    drop_table :base_mail_template_kinds
  end
end
