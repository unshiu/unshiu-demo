module Jpmobile::Model
  class JpmobileCarrier < ActiveRecord::Base
    has_many :jpmobile_devices
    
  end
end
