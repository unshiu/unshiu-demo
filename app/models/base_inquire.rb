# == Schema Information
#
# Table name: base_inquires
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)
#  body         :text
#  referer      :string(255)
#  mail_address :string(255)
#  base_user_id :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

class BaseInquire < ActiveRecord::Base
  include BaseInquireModule
end
