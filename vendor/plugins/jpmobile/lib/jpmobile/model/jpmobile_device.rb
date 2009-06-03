module Jpmobile::Model
  class JpmobileDevice < ActiveRecord::Base 
    belongs_to :jpmobile_carrier
  
    # 機情報を永続化する
    # _param1_:: carrier_id
    # _param2_:: device_info
    def self.save_from_hash(carrier_id, device_info)
      device_info.each_pair do |key, value|
        jpmobile_device = find(:first, :conditions => ['device = ?', key])
      
        if jpmobile_device.nil?
          jpmobile_device = self.new
          jpmobile_device.jpmobile_carrier_id = carrier_id
          jpmobile_device.device = key
          jpmobile_device.attributes = value
          jpmobile_device.save
        
        elsif value[:updated_at].nil? || Time.parse(value[:updated_at]) > jpmobile_device.updated_at 
          jpmobile_device.attributes = value
          jpmobile_device.save
        end
      end
    end
  
  end
end