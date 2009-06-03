# == Schema Information
#
# Table name: base_mail_dispatch_infos
#
#  id           :integer(4)      not null, primary key
#  mail_address :string(255)
#  model_name   :string(255)
#  method_name  :string(255)
#  model_id     :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#  base_user_id :integer(4)
#

class BaseMailDispatchInfo < ActiveRecord::Base
  include BaseMailDispatchInfoModule
end
