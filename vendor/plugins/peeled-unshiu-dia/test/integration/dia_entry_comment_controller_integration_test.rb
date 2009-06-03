require "#{File.dirname(__FILE__)}/../test_helper"

module DiaEntryCommentControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 記事コメントの一覧画面を表示しようとするが閲覧権限がないのでみれない') do 
    post "base_user/login", :login => "three", :password => "test"
    
    post "dia_entry_comment/list", :id => 8 # id = 8 の日記記事は友達までの公開
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04001"
  end
  
  define_method('test: コメントを削除する確認画面を表示しようとするが、日記所有者でもコメントを書いた人でもないのでエラー画面へ遷移') do
    post "base_user/login", :login => "five", :password => "test"
    
    post "dia_entry_comment/delete_confirm", :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04002"    
  end
  
end