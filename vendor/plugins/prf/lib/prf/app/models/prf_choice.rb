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

module PrfChoiceModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid

        # -------------------------
        # validate
        # -------------------------
        validates_presence_of :prf_profile_id, :body, :free_area_type

        # -------------------------
        # relation
        # -------------------------
        belongs_to :prf_question
        belongs_to :prf_profile
        has_many :prf_answers, :dependent => :destroy

        # -------------------------
        # context
        # -------------------------
        const_set('CHOICE_FREE_AREA_TYPE_NONE',     0)
        const_set('CHOICE_FREE_AREA_TYPE_TEXT',     1)
        const_set('CHOICE_FREE_AREA_TYPE_TEXTAREA', 2)
        
        I18n.t('activerecord.constant.type.none')
        I18n.t('activerecord.constant.type.text')
        I18n.t('activerecord.constant.type.textarea')
      end
    end
  end
  
  def has_free_area?
    return free_area_type != PrfChoice::CHOICE_FREE_AREA_TYPE_NONE
  end
  def free_area_type_text?
    return free_area_type == PrfChoice::CHOICE_FREE_AREA_TYPE_TEXT
  end
  def free_area_type_textarea?
    return free_area_type == PrfChoice::CHOICE_FREE_AREA_TYPE_TEXTAREA
  end
end

