# == Schema Information
#
# Table name: dia_diaries
#
#  id                   :integer(4)      not null, primary key
#  base_user_id         :integer(4)      not null
#  default_public_level :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  deleted_at           :datetime
#

class DiaDiary < ActiveRecord::Base
  include DiaDiaryModule
end
