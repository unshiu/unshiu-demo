# == Schema Information
#
# Table name: base_notices
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  body           :text
#  start_datetime :datetime
#  end_datetime   :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

class BaseNotice < ActiveRecord::Base
  include BaseNoticeModule
end
