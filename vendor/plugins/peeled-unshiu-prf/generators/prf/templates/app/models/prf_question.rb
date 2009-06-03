# == Schema Information
#
# Table name: prf_questions
#
#  id               :integer(4)      not null, primary key
#  prf_profile_id   :integer(4)      not null
#  question_type    :integer(4)
#  body             :text
#  active_flag      :boolean(1)
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#  open_accept_type :integer(4)
#

class PrfQuestion < ActiveRecord::Base
  include PrfQuestionModule
end
