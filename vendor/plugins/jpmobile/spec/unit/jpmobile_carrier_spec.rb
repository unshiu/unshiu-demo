require File.join(File.dirname(__FILE__), 'spec_helper')
require 'jpmobile/model/jpmobile_device'
require 'jpmobile/model/jpmobile_carrier'

describe Jpmobile::Model::JpmobileCarrier do
  
  before do
    database = YAML.load_file(File.expand_path('config/database.yml'))
    ActiveRecord::Base.establish_connection(database["test"]["jpmobile"])
    Jpmobile::Model::JpmobileDevice.delete_all
    Jpmobile::Model::JpmobileCarrier.delete_all
  end
  
  it 'このキャリアで登録しているデバイス数を取得する' do
    jpmobile_carrier = Jpmobile::Model::JpmobileCarrier.new({:name => "docomo"})
    jpmobile_carrier.save!
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.new({:jpmobile_carrier_id => jpmobile_carrier.id, :device => "AI011ST"})
    jpmobile_device.save!
    
    jpmobile_carrier.jpmobile_devices.count.should == 1
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.new({:jpmobile_carrier_id => -1, :device => "AI011ST"})
    jpmobile_device.save!
    
    jpmobile_carrier.jpmobile_devices.count.should == 1
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.new({:jpmobile_carrier_id => jpmobile_carrier.id, :device => "AI011ST"})
    jpmobile_device.save!
    
    jpmobile_carrier.jpmobile_devices.count.should == 2
    
  end
  
end