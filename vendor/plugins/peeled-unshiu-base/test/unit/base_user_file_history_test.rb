require File.dirname(__FILE__) + '/../test_helper'

module BaseUserFileHistoryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :base_users
        fixtures :base_user_file_histories
      end
    end
  end
  
  define_method('test: ランダムなファイル名を生成する') do 
    base_user_file_history = BaseUserFileHistory.new
    base_user_file_history.create_csv_file_name
    assert_equal(base_user_file_history.file_name.size, 34) # ランダムなので桁数だけ確認
  end
  
  define_method('test: 処理が完了しているかどうかを判断する') do 
    base_user_file_history = BaseUserFileHistory.new
    assert_nil(base_user_file_history.complated_at) # 完了日付はない
    assert_equal(base_user_file_history.complated?, false) # 完了していない
  
    base_user_file_history = BaseUserFileHistory.find(2)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付がある
    assert_equal(base_user_file_history.complated?, true) # 完了している
  end
  
  define_method('test: ファイルフルパスを取得する') do 
    base_user_file_history = BaseUserFileHistory.find(1)
    
    path = "#{RAILS_ROOT}/#{AppResources[:base][:user_csv_file_path]}/"
    assert_equal(base_user_file_history.file_full_path_name, path + base_user_file_history.file_name)
  end
  
  define_method('test: ダウンロードする際のコンテンツタイプを取得する') do 
    base_user_file_history = BaseUserFileHistory.find(2)
    
    assert_equal(base_user_file_history.content_type, "text/csv;charset=UTF-8")
  end
end
