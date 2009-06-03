# == Schema Information
#
# Table name: base_active_histories
#
#  id          :integer(4)      not null, primary key
#  history_day :date
#  before_days :integer(4)
#  user_count  :integer(4)
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class BaseActiveHistory < ActiveRecord::Base
  include BaseActiveHistoryModule
end
