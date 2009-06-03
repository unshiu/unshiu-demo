require File.dirname(__FILE__) + '/../test_helper'

module PrfQuestionSetTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :prf_question_sets  
        fixtures :prf_question_set_partials  
        fixtures :prf_questions
        fixtures :prf_choices
      end
    end
  end
  
  # リレーションのテスト
  def test_relation
    prf_question_set = PrfQuestionSet.find(1)
    assert_not_nil prf_question_set.prf_question_set_partials
  end
  
  # 基本プロフィール項目を取得する　find_basic_profileのテスト
  def test_find_basic_profile
    prf_question_set = PrfQuestionSet.find_basic_profile
    assert_not_nil prf_question_set.prf_question_set_partials
    
    # テストデータ 設問6件
    assert_equal(prf_question_set.prf_question_set_partials.size, 7) # FIXME テストデータの値チェックをしても意味がない
  end
    
end