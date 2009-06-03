# == Schema Information
#
# Table name: base_errors
#
#  id         :integer(4)      not null, primary key
#  error_code :string(255)     not null
#  message    :text            default(""), not null
#  coping     :text            default(""), not null
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class BaseError < ActiveRecord::Base
  include BaseErrorModule
end
