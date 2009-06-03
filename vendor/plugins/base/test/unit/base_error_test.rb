require File.dirname(__FILE__) + '/../test_helper'

module BaseErrorTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: エラーコードを取得する') do 
    base_error = BaseError.find_by_error_code_use_default("U-00001")
    
    assert_not_nil base_error
    assert_equal base_error.message, "申し訳ございません。ページが見つかりませんでした。"
  end
  
  define_method('test: 存在しないエラーコードでエラー情報を取得しようとするので標準エラー情報がかえる') do 
    base_error = BaseError.find_by_error_code_use_default("X-999")
    
    assert_not_nil base_error
    assert_equal base_error.message, "致命的なエラーが発生しました。"
  end
end
