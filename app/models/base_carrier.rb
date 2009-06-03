# == Schema Information
#
# Table name: base_carriers
#
#  id         :integer(4)      not null, primary key
#  name       :string(256)     default(""), not null
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class BaseCarrier < ActiveRecord::Base
  include BaseCarrierModule
end
