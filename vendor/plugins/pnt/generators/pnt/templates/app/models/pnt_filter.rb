# == Schema Information
#
# Table name: pnt_filters
#
#  id                   :integer(4)      not null, primary key
#  pnt_master_id        :integer(4)      not null
#  point                :integer(4)      not null
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  deleted_at           :datetime
#  summary              :string(200)
#  pnt_filter_master_id :integer(4)      not null
#  start_at             :datetime
#  end_at               :datetime
#  rule_day             :integer(4)
#  rule_count           :integer(4)
#  stock                :integer(4)
#

class PntFilter < ActiveRecord::Base
  include PntFilterModule
end
