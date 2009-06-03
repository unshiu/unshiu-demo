# == Schema Information
#
# Table name: cmm_tags
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class CmmTag < ActiveRecord::Base
  include CmmTagModule
end
