require File.dirname(__FILE__) + '/../test_helper'

module DiaEntryCommentControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        
        fixtures :base_users
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
      end
    end
  end
  
  define_method('test: list は記事コメントの一覧画面を表示する') do 
    login_as :quentin
    
    post :list, :id => 1
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: list は閲覧権限を確認した上で記事コメントの一覧画面を表示') do 
    login_as :aaron
    
    post :list, :id => 8 # id = 8 の日記記事は友達までの公開でaaronは友達
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: list は閲覧権限がない記事のコメントの一覧画面は表示せずエラー画面へ遷移する') do 
    login_as :three
    
    post :list, :id => 8 # id = 8 の日記記事は友達までの公開
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: create_remote はコメントを新規作成する') do 
    login_as :quentin
    
    assert_difference 'DiaEntryComment.count', 1 do
      post :create_remote, :id => 1, :comment => { :body => 'コメントを新規作成する' }
      assert_response :success
      assert_not_nil(assigns["comments"])
      assert_rjs :visual_effect, :highlight, "dia_entry_comment_message" 
    end
  end
  
  define_method('test: create_remote はコメントを新規作成しようとするが、本文が空なのでエラーが表示されコメントが投稿されない') do 
    login_as :three
    
    before_dia_comment_count = DiaEntryComment.count
    
    assert_difference 'DiaEntryComment.count', 0 do # 増えない
      post :create_remote, :id => 1, :comment => { :body => '' }
      assert_response :success
      assert_nil(assigns["comments"])
      assert_rjs :visual_effect, :highlight, "dia_entry_comment_message"
    end
  end
  
  define_method('test: delete_confirm はコメントを削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm'
  end
  
  define_method('test: delete_confirm は日記所有者でもコメントを書いた人でもなければエラー画面へ遷移') do 
    login_as :five
    
    post :delete_confirm, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: delete はコメントを削除を実行する') do 
    login_as :quentin
    
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :controller => 'dia_entry', :action => 'show', :id => 2
    
    dia_entry_comment = DiaEntryComment.find_by_id(1)
    assert_not_nil dia_entry_comment 
    assert_equal dia_entry_comment.invisibled_by_anyone?, true # deleterがある場合は deleted_at は存在し、deleter値だけ更新
  end
  
  define_method('test: delete は日記所有者でもコメントを書いた人でもない場合はのでエラー画面へ遷移') do 
    login_as :five
    
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    dia_entry_comment = DiaEntryComment.find_by_id(1)
    assert_not_nil dia_entry_comment 
    assert_equal dia_entry_comment.not_invisibled_by_anyone?, true # 削除処理は実行されていない
  end
  
  define_method('test: delete はキャンセルボタンを押されたらコメントを削除を実行せずに記事画面に戻る') do 
    login_as :quentin
    
    post :delete, :id => 1, :cancel => "true"
    assert_response :redirect 
    assert_redirected_to :controller => 'dia_entry', :action => 'show', :id => 2
    
    dia_entry_comment = DiaEntryComment.find_by_id(1)
    assert_not_nil dia_entry_comment 
    assert_equal dia_entry_comment.invisibled_by_anyone?, false # 削除されてない
  end
end
