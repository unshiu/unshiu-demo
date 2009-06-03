require File.dirname(__FILE__) + '/../test_helper'

module DiaEntryCommentControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        
        fixtures :base_users
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
      end
    end
  end
  
  define_method('test: 記事コメントの一覧画面を表示する') do 
    login_as :quentin
    
    post :list, :id => 1
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: 閲覧権限がある記事コメントの一覧画面を表示') do 
    login_as :aaron
    
    post :list, :id => 8 # id = 8 の日記記事は友達までの公開でaaronは友達
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: 記事コメントの一覧画面を表示しようとするが閲覧権限がないのでみれない') do 
    login_as :three
    
    post :list, :id => 8 # id = 8 の日記記事は友達までの公開
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: コメントを新規作成する') do 
    login_as :quentin
    
    post :new, :id => 1
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 閲覧権限がある記事のコメントを新規作成する') do 
    login_as :aaron
    
    post :new, :id => 7 # id = 7 の日記記事は友達の友達までの公開でaaronは友達
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 閲覧権限がある記事のコメントを新規作成しようとするが閲覧権限がないのでエラー画面へ遷移') do 
    login_as :three
    
    post :new, :id => 7 # id = 7 の日記記事は友達の友達までの公開
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: コメントを新規作成の確認画面を表示') do 
    login_as :quentin
    
    post :confirm, :id => 1, :comment => { :body => 'コメントを新規作成の確認画面を表示' }
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: コメントを新規作成の確認画面を表示しようとするが、本文未入力のため作成画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :id => 1, :comment => { :body => '' }
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: コメントを新規作成の確認画面を表示しようとするが、閲覧権限がないのでエラー画面へ遷移') do 
    login_as :three
    
    post :confirm, :id => 7, :comment => { :body => '閲覧権限がないのでエラー画面へ遷移' }
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: コメントを新規作成する') do 
    login_as :quentin
    
    # 事前チェック：まだコメントは存在していない
    before_dia_comment_count = DiaEntryComment.count
    
    post :create, :id => 1, :comment => { :body => 'コメントを新規作成する' }
    assert_response :redirect 
    assert_redirected_to :controller => 'dia_entry_comment', :action => 'done', :id => 1
    
    after_dia_comment_count = DiaEntryComment.count
    assert_equal after_dia_comment_count, before_dia_comment_count+1 # コメントが作成されている
  end
  
  define_method('test: コメントを新規作成しようとするが、閲覧権限がないのでエラー画面へ遷移') do 
    login_as :three
    
    before_dia_comment_count = DiaEntryComment.count
    
    post :create, :id => 7, :comment => { :body => '閲覧権限がないのでエラー画面へ遷移' }
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    after_dia_comment_count = DiaEntryComment.count
    assert_equal after_dia_comment_count, before_dia_comment_count # コメントが作成されていない
  end
  
  define_method('test: コメントを削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm_mobile'
  end
  
  define_method('test: コメントを削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm_mobile'
  end
  
  define_method('test: コメントを削除する確認画面を表示しようとするが、日記所有者でもコメントを書いた人でもないのでエラー画面へ遷移') do 
    login_as :five
    
    post :delete_confirm, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: コメントを削除を実行する') do 
    login_as :quentin
    
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'delete_done'
    
    dia_entry_comment = DiaEntryComment.find_by_id(1)
    assert_not_nil dia_entry_comment 
    assert_equal dia_entry_comment.invisibled_by_anyone?, true # deleterがある場合は deleted_at は存在し、deleter値だけ更新
  end
  
  define_method('test: コメントを削除を実行しようとするが、日記所有者でもコメントを書いた人でもないのでエラー画面へ遷移') do 
    login_as :five
    
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    dia_entry_comment = DiaEntryComment.find_by_id(1)
    assert_not_nil dia_entry_comment 
    assert_equal dia_entry_comment.not_invisibled_by_anyone?, true # 削除処理は実行されていない
  end
end
