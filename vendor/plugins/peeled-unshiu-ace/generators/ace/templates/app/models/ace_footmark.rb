# == Schema Information
#
# Table name: ace_footmarks
#
#  id                 :integer(4)      not null, primary key
#  base_user_id       :string(255)     not null
#  footmarked_user_id :integer(4)      not null
#  place              :string(128)     not null
#  uuid               :string(128)     not null
#  count              :integer(4)      default(0), not null
#  deleted_at         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

class AceFootmark < ActiveRecord::Base
  include AceFootmarkModule
end
