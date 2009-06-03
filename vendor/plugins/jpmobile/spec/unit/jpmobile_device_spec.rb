require File.join(File.dirname(__FILE__), 'spec_helper')
require 'jpmobile/model/jpmobile_device'

describe Jpmobile::Model::JpmobileDevice do
  
  before do
    database = YAML.load_file(File.expand_path('config/database.yml'))
    ActiveRecord::Base.establish_connection(database["test"]["jpmobile"])
    Jpmobile::Model::JpmobileDevice.delete_all
  end

  it 'hash情報をテーブルに保存する' do
    device = 
    {"N600i"=>
      {:gps=>false,
       :gif=>true,
       :jpg=>true,
       :name=>"N600i SIMPURE N",
       :png=>false,
       :flash=>false,
       :flash_version=>nil,
       :ssl=>false},
    "P900iV"=>
       {:gps=>true,
        :gif=>true,
        :jpg=>true,
        :name=>"P900iV",
        :png=>false,
        :flash=>false,
        :flash_version=>"1.0",
        :ssl=>false}
    }
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.save_from_hash(1, device)
    
    device = Jpmobile::Model::JpmobileDevice.find_by_device("N600i")
    device.should_not nil
    device.gps?.should be_false
    device.gif?.should be_true
    device.jpg?.should be_true
    device.name.should == "N600i SIMPURE N"
    device.png?.should be_false
    device.flash?.should be_false
    
    device = Jpmobile::Model::JpmobileDevice.find_by_device("P900iV")
    device.should_not nil
    device.name.should == "P900iV"
  end
  
end