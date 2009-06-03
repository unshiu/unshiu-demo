# == Schema Information
#
# Table name: pnt_masters
#
#  id         :integer(4)      not null, primary key
#  title      :string(200)     default(""), not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  deleted_at :datetime
#

class PntMaster < ActiveRecord::Base
  include PntMasterModule
  
end
