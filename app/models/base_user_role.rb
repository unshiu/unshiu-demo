# == Schema Information
#
# Table name: base_user_roles
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)
#  role         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

class BaseUserRole < ActiveRecord::Base
  include BaseUserRoleModule
end
