# == Schema Information
#
# Table name: pnt_file_update_histories
#
#  id            :integer(4)      not null, primary key
#  file_name     :string(256)     default(""), not null
#  record_count  :integer(4)
#  success_count :integer(4)
#  fail_count    :integer(4)
#  complated_at  :datetime
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  deleted_at    :datetime
#

class PntFileUpdateHistory < ActiveRecord::Base
  include PntFileUpdateHistoryModule
end
