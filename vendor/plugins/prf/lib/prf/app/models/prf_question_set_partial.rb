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

module PrfQuestionSetPartialModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid

        belongs_to :prf_question
        belongs_to :prf_question_set
      end
    end
  end
  
end
