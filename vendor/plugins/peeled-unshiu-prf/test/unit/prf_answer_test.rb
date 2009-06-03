require File.dirname(__FILE__) + '/../test_helper'

module PrfAnswerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :prf_answers
        fixtures :prf_questions
        fixtures :prf_choices
        fixtures :prf_profiles
        fixtures :base_ng_words
      end
    end
  end
  
  define_method('test: 関連の取得') do
    prf_answer = PrfAnswer.find(1)
    assert_not_nil prf_answer
    assert_not_nil(prf_answer.prf_profile)
    assert_not_nil(prf_answer.prf_question)
    assert_not_nil(prf_answer.prf_choice_id)
  end
  
  define_method('test: 回答本文にNGワードがいれられた場合保存できない') do
    prf_answer = PrfAnswer.find(1)
    prf_answer.body = 'NGワード:aaa'
    assert_equal(prf_answer.save, false)
  end
end
