# == Schema Information
#
# Table name: base_users
#
#  id                         :integer(4)      not null, primary key
#  login                      :string(255)
#  email                      :string(255)
#  crypted_password           :string(40)
#  salt                       :string(40)
#  created_at                 :datetime
#  updated_at                 :datetime
#  remember_token             :string(255)
#  remember_token_expires_at  :datetime
#  deleted_at                 :datetime
#  status                     :integer(4)
#  activation_code            :string(255)
#  crypted_uid                :string(255)
#  joined_at                  :datetime
#  quitted_at                 :datetime
#  new_email                  :string(255)
#  receive_system_mail_flag   :boolean(1)
#  receive_mail_magazine_flag :boolean(1)
#  message_accept_level       :integer(4)      default(2), not null
#  footmark_flag              :boolean(1)      default(TRUE), not null
#  base_carrier_id            :integer(4)
#  device_name                :string(255)
#  name                       :string(255)
#

class BaseUser < ActiveRecord::Base
  include BaseUserModule
end
