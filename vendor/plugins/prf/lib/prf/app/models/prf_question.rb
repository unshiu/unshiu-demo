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

module PrfQuestionModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid

        # -------------------------
        # validate
        # -------------------------
        validates_presence_of  :prf_profile_id, :body, :active_flag  
        validates_inclusion_of :active_flag, :in => [ true, false ]
        validates_inclusion_of :question_type, :in => 1..5
        
        # -------------------------
        # relation
        # -------------------------
        has_many :prf_choices, :dependent => :destroy
        has_many :prf_question_set_partials, :dependent => :destroy

        # -------------------------
        # context
        # -------------------------
        const_set('QUESTION_TYPE_RADIO',    1)
        const_set('QUESTION_TYPE_SELECT',   2)
        const_set('QUESTION_TYPE_CHECKBOX', 3)
        const_set('QUESTION_TYPE_TEXT',     4)
        const_set('QUESTION_TYPE_TEXTAREA', 5)
        
        const_set('OPEN_ACCEPT_TYPE_OPEN',       0)
        const_set('OPEN_ACCEPT_TYPE_CLOSE',      1)
        const_set('OPEN_ACCEPT_TYPE_SELECTABLE', 2)
        
      end
    end
  end
    
  def type_select?
    return question_type == PrfQuestion::QUESTION_TYPE_SELECT
  end
  def type_radio?
    return question_type == PrfQuestion::QUESTION_TYPE_RADIO
  end
  def type_checkbox?
    return question_type == PrfQuestion::QUESTION_TYPE_CHECKBOX
  end
  def type_text?
    return question_type == PrfQuestion::QUESTION_TYPE_TEXT
  end
  def type_textarea?
    return question_type == PrfQuestion::QUESTION_TYPE_TEXTAREA
  end
  def selectable?
    return type_select? || type_radio? || type_checkbox?
  end
  
  def answer_by_prf_profile_id(prf_profile_id)
    if type_checkbox?
      return PrfAnswer.find(:all, :order => "id asc",
        :conditions => ["prf_profile_id = ? and prf_question_id = ?", prf_profile_id, id])
    else
      return PrfAnswer.find_by_prf_profile_id_and_prf_question_id(prf_profile_id, id)
    end
  end
  
end
