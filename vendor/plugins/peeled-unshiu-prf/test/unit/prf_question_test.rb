require File.dirname(__FILE__) + '/../test_helper'

module PrfQuestionTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :prf_questions
        fixtures :prf_choices
      end
    end
  end
  
  # リレーションのテスト
  def test_relation
    prf_question = PrfQuestion.find(1)
    assert_not_nil prf_question.prf_choices
    assert_not_nil prf_question.prf_question_set_partials
  end
  
  # ラジオボタンの質問か判定するテスト
  def test_type_radio?
    assert PrfQuestion.find(7).type_radio?
    assert !PrfQuestion.find(8).type_radio?
    assert !PrfQuestion.find(9).type_radio?
    assert !PrfQuestion.find(10).type_radio?
    assert !PrfQuestion.find(11).type_radio?
  end
  
  # セレクトボックスの質問か判定するテスト
  def test_type_select?
    assert !PrfQuestion.find(7).type_select?
    assert PrfQuestion.find(8).type_select?
    assert !PrfQuestion.find(9).type_select?
    assert !PrfQuestion.find(10).type_select?
    assert !PrfQuestion.find(11).type_select?
  end
  
  # チェックボックスの質問か判定するテスト
  def test_type_checkbox?
    assert !PrfQuestion.find(7).type_checkbox?
    assert !PrfQuestion.find(8).type_checkbox?
    assert PrfQuestion.find(9).type_checkbox?
    assert !PrfQuestion.find(10).type_checkbox?
    assert !PrfQuestion.find(11).type_checkbox?
  end
  
  # テキストの質問か判定するテスト
  def test_type_text?
    assert !PrfQuestion.find(7).type_text?
    assert !PrfQuestion.find(8).type_text?
    assert !PrfQuestion.find(9).type_text?
    assert PrfQuestion.find(10).type_text?
    assert !PrfQuestion.find(11).type_text?
  end
  
  # テキストエリアの質問か判定するテスト
  def test_type_textarea?
    assert !PrfQuestion.find(7).type_textarea?
    assert !PrfQuestion.find(8).type_textarea?
    assert !PrfQuestion.find(9).type_textarea?
    assert !PrfQuestion.find(10).type_textarea?
    assert PrfQuestion.find(11).type_textarea?
  end
  
  # 選択肢系の質問か判定するテスト
  def test_selectable?
    assert PrfQuestion.find(7).selectable?
    assert PrfQuestion.find(8).selectable?
    assert PrfQuestion.find(9).selectable?
    assert !PrfQuestion.find(10).selectable?
    assert !PrfQuestion.find(11).selectable?
  end
  
  # プロフィールの回答を探すテスト
  def test_answer_by_prf_profile_id
    # 対象の設問を取得
    question = PrfQuestion.find(1)
    
    # 回答の取得
    assert_not_nil answer = question.answer_by_prf_profile_id(1)
    assert_equal 1, answer.prf_profile_id
    assert_equal 1, answer.prf_question_id

    
    # 対象の設問を取得
    question = PrfQuestion.find(6)
    
    # 回答の取得
    assert_not_nil answers = question.answer_by_prf_profile_id(1)
    assert !answers.empty?
    assert_equal 2, answers.size
    assert_equal 1, answers[0].prf_profile_id
    assert_equal 6, answers[0].prf_question_id
    assert_equal 1, answers[1].prf_profile_id
    assert_equal 6, answers[1].prf_question_id
  end
end