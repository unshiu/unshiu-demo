# == Schema Information
#
# Table name: pnt_filter_masters
#
#  id              :integer(4)      not null, primary key
#  title           :string(500)     default(""), not null
#  controller_name :string(256)     default(""), not null
#  action_name     :string(256)     default(""), not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  deleted_at      :datetime
#

class PntFilterMaster < ActiveRecord::Base
  include PntFilterMasterModule
end
