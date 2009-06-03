# == Schema Information
#
# Table name: pnt_points
#
#  id            :integer(4)      not null, primary key
#  base_user_id  :integer(4)      not null
#  point         :integer(4)      default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :datetime
#  pnt_master_id :integer(4)      not null
#

class PntPoint < ActiveRecord::Base
  include PntPointModule
end
