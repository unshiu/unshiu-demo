# == Schema Information
#
# Table name: pnt_update_error_records
#
#  id                         :integer(4)      not null, primary key
#  pnt_file_update_hisotry_id :integer(4)      not null
#  line_number                :integer(4)      not null
#  record                     :string(255)     default(""), not null
#  reason                     :string(1000)    default(""), not null
#  created_at                 :datetime        not null
#  updated_at                 :datetime        not null
#  deleted_at                 :datetime
#

class PntUpdateErrorRecord < ActiveRecord::Base
  include PntUpdateErrorRecordModule
end
