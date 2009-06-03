require File.dirname(__FILE__) + '/../../test_helper'

module Manage::DiaEntryCommentControllerTestModule
    
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        
        fixtures :base_users
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :dia_entries_abm_images
        fixtures :abm_images
        fixtures :abm_albums
      end
    end
  end
  
  define_method('test: 記事コメント一覧画面を表示する') do 
    login_as :quentin
  
    post :list
    assert_response :success
    assert_template 'list'
    
    assert_not_nil(assigns(:comments))
  end
  
  define_method('test: 記事コメント削除確認画面を表示する') do 
    login_as :quentin
  
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm'
  end

  define_method('test: 記事コメント削除を実行する') do 
    login_as :quentin
  
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :controller => 'manage/dia_entry', :action => 'show', :id => 2
  
    dia_entry_comment = DiaEntryComment.find_by_id(1)
    assert_not_nil dia_entry_comment # 実体は存在している
    assert dia_entry_comment.invisibled_by_manager?
  end

  define_method('test: 記事コメント削除のキャンセルをする') do 
    login_as :quentin
  
    post :delete, :id => 1, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :controller => 'manage/dia_entry', :action => 'show'
  
    dia_entry_comment = DiaEntryComment.find_by_id(1)
    assert_not_nil dia_entry_comment # 実体は存在している
    assert_equal dia_entry_comment.invisibled_by, nil # キャンセルされているので削除はされてない
  end
end