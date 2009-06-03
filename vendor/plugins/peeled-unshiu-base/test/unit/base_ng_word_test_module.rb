require File.dirname(__FILE__) + '/../test_helper'

module BaseNgWordTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_ng_words
      end
    end
  end

  # 有効フラグの文字列表現のテスト
  def test_active_str
    # 有効
    ng_word = BaseNgWord.find(1)
    ng_word.active_str

    # 無効
    ng_word = BaseNgWord.find(3)
    ng_word.active_str
  end
  
  # 有効なNGワード一覧の取得
  def test_active_words
    assert_equal 2, BaseNgWord.active_words.size
  end
  
  # NGワード正規表現の取得
  def test_regexp
    # テストは DB を直接いじるので正規表現を refresh するために適当に保存する
    BaseNgWord.find(1).save
    
    # 正規表現の取得
    regexp = BaseNgWord.regexp
    assert_not_nil regexp
    
    # 一致テスト
    ng_words = BaseNgWord.active_words
    ng_words.each do |ng_word|
      assert regexp =~ ng_word
    end
  end

end