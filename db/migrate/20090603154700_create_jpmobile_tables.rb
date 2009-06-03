class CreateJpmobileTables < ActiveRecord::Migration
  def self.up
    create_table :jpmobile_carriers, :force => true do |t|
      t.column :name,                     :string
      t.column :available_flag,           :boolean, :default => true
      t.column :created_at,               :datetime
      t.column :updated_at,               :datetime
    end
    
    add_index :jpmobile_carriers, :name
    
    ['docomo', 'au', 'softbank', 'willcom'].each do |name|
      jpmobile_carrier = Jpmobile::Model::JpmobileCarrier.new({:name => name})
      jpmobile_carrier.save
    end
    
    create_table :jpmobile_devices, :force => true do |t|
      t.column :jpmobile_carrier_id,      :integer
      t.column :model,                    :string
      t.column :device,                   :string
      t.column :name,                     :string
      t.column :gps,                      :boolean
      t.column :jpg,                      :boolean
      t.column :gif,                      :boolean
      t.column :png,                      :boolean
      t.column :flash,                    :boolean
      t.column :flash_version,            :string
      t.column :ssl,                      :boolean
      t.column :color,                    :boolean
      t.column :colors,                   :integer
      t.column :chord,                    :integer
      t.column :ringer_melody_song,       :boolean
      t.column :ringer_melody_song_full,  :boolean
      t.column :ringer_melody_movie,      :boolean
      t.column :qr,                       :boolean
      t.column :bluetooth,                :boolean
      t.column :available_flag,           :boolean, :default => true
      t.column :created_at,               :datetime
      t.column :updated_at,               :datetime
    end
    
    add_index :jpmobile_devices, :jpmobile_carrier_id
    add_index :jpmobile_devices, :device
    
    create_table :jpmobile_displays, :force => true do |t|
      t.column :jpmobile_carrier_id,      :integer
      t.column :device,                   :string
      t.column :browser_width,            :integer
      t.column :browser_height,           :integer
      t.column :created_at,               :datetime
      t.column :updated_at,               :datetime
    end
    
    add_index :jpmobile_displays, :jpmobile_carrier_id
    add_index :jpmobile_displays, :device
        
    create_table :jpmobile_ipaddresses, :force => true do |t|
      t.column :jpmobile_carrier_id,      :integer
      t.column :ip_address,               :string
      t.column :created_at,               :datetime
      t.column :updated_at,               :datetime
    end
    
    add_index :jpmobile_ipaddresses, :jpmobile_carrier_id
    add_index :jpmobile_ipaddresses, :ip_address
    
  end

  def self.down
    drop_table :jpmobile_devices
    drop_table :jpmobile_carriers
    drop_table :jpmobile_displays
    drop_table :jpmobile_ipaddresses
  end
end