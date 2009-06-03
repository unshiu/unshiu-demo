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

module PrfAnswerModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid

        belongs_to :prf_choice
        belongs_to :prf_question
        belongs_to :prf_profile

        validates_good_word_of :body
      end
    end
  end
  
end
