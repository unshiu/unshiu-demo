# == Schema Information
#
# Table name: mng_user_action_histories
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  user_action  :text            default(""), not null
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class MngUserActionHistory < ActiveRecord::Base
  belongs_to :base_user
  
end
