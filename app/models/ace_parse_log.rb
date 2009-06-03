# == Schema Information
#
# Table name: ace_parse_logs
#
#  id             :integer(4)      not null, primary key
#  client_id      :integer(4)      not null
#  filename       :string(128)     not null
#  complate_point :integer(4)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class AceParseLog < ActiveRecord::Base
  include AceParseLogModule
end
