# == Schema Information
#
# Table name: prf_choices
#
#  id              :integer(4)      not null, primary key
#  prf_question_id :integer(4)      not null
#  prf_profile_id  :integer(4)      not null
#  body            :text
#  free_area_type  :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#

class PrfChoice < ActiveRecord::Base
  include PrfChoiceModule
end

