# == Schema Information
#
# Table name: pnt_histories
#
#  id            :integer(4)      not null, primary key
#  pnt_point_id  :integer(4)      not null
#  difference    :integer(4)      default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :datetime
#  message       :string(2000)    default(""), not null
#  pnt_filter_id :integer(4)
#

class PntHistory < ActiveRecord::Base
  include PntHistoryModule
end
