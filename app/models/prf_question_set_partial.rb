# == Schema Information
#
# Table name: prf_question_set_partials
#
#  id                  :integer(4)      not null, primary key
#  prf_question_set_id :integer(4)      not null
#  prf_question_id     :integer(4)      not null
#  order_num           :integer(4)
#  required_flag       :boolean(1)
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#

class PrfQuestionSetPartial < ActiveRecord::Base
  include PrfQuestionSetPartialModule
end
