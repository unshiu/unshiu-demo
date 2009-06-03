# == Schema Information
#
# Table name: base_profiles
#
#  id                        :integer(4)      not null, primary key
#  base_user_id              :integer(4)      not null
#  name                      :string(100)
#  name_public_level         :integer(4)
#  kana_name                 :string(100)
#  kana_name_public_level    :integer(4)
#  introduction              :text
#  introduction_public_level :integer(4)
#  sex                       :integer(4)
#  sex_public_level          :integer(4)
#  civil_status              :integer(4)
#  civil_status_public_level :integer(4)
#  birthday                  :date
#  birthday_public_level     :integer(4)
#  created_at                :datetime
#  updated_at                :datetime
#  deleted_at                :datetime
#  image                     :string(255)
#  area                      :string(255)
#  area_public_level         :integer(4)
#

class BaseProfile < ActiveRecord::Base
  include BaseProfileModule
end
