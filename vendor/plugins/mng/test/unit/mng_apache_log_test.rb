require File.dirname(__FILE__) + '/../test_helper'

module MngApacheLogTestModule
  
  define_method('test: アクセスログファイル一覧を取得する') do 
    apache_logs = MngApacheLog.find_all
    assert_not_nil(apache_logs)
    assert_not_equal(apache_logs.size, 0)
    
    apache_logs.each do |apache_log| # 各要素をとれているか
      assert_not_nil(apache_log.filename)
      assert_not_nil(apache_log.filesize)
    end
  end
  
end
