# == Schema Information
#
# Table name: prf_answers
#
#  id              :integer(4)      not null, primary key
#  prf_question_id :integer(4)      not null
#  prf_choice_id   :integer(4)      not null
#  prf_profile_id  :integer(4)      not null
#  body            :text
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#

class PrfAnswer < ActiveRecord::Base
  include PrfAnswerModule
end
