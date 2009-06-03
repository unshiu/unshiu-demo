require File.dirname(__FILE__) + '/../test_helper'

module BaseNoticeTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_notices
      end
    end
  end

  def test_current_notices
    # 中で Time.now 使ってるのでちゃんとしたテストが面倒なの。。。
    assert_not_nil BaseNotice.current_notices
  end
  
  # お知らせ一覧の取得テスト
  def test_all_notices
    # 全件取得
    notices = BaseNotice.all_notices
    assert_not_nil notices
    assert_equal 2, notices.size
    
    # paginate
    notices = BaseNotice.all_notices(:page => {:size => 1, :current => nil})
    assert_not_nil notices
    notices.load_page
    assert_equal 1, notices.results.size
  end

end