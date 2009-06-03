# == Schema Information
#
# Table name: base_user_file_histories
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  file_name    :string(255)     not null
#  complated_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class BaseUserFileHistory < ActiveRecord::Base
  include BaseUserFileHistoryModule
end
