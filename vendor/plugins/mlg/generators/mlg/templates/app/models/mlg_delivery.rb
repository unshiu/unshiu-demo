# == Schema Information
#
# Table name: mlg_deliveries
#
#  id              :integer(4)      not null, primary key
#  base_user_id    :integer(4)      not null
#  mlg_magazine_id :integer(4)      not null
#  sended_at       :datetime
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  deleted_at      :datetime
#

class MlgDelivery < ActiveRecord::Base
  include MlgDeliveryModule
end
