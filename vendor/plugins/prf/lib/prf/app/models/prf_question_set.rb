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

module PrfQuestionSetModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        has_many :prf_question_set_partials, :order => 'order_num', :dependent => :destroy

        # const
        # プロフィール種別: id　=　1　は仕様として基本プロフィールセット
        const_set('KIND_BASIC_ID',    1)
        
      end
    end
  end
  
  module ClassMethods
    # 基本プロフィールセットを取得する
    # return  :: PrfQuestionSet
    def find_basic_profile
      find(PrfQuestionSet::KIND_BASIC_ID)
    end
  end

end
