# == Schema Information
#
# Table name: prf_question_sets
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class PrfQuestionSet < ActiveRecord::Base
  include PrfQuestionSetModule
end
