# == Schema Information
#
# Table name: pnt_history_summaries
#
#  id              :integer(4)      not null, primary key
#  start_at        :datetime        not null
#  end_at          :datetime        not null
#  sum_issue_point :integer(4)      not null
#  sum_use_point   :integer(4)      not null
#  record_count    :integer(4)      not null
#  file_name       :string(256)     default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  kind_type       :integer(4)      not null
#

class PntHistorySummary < ActiveRecord::Base
  include PntHistorySummaryModule
end
