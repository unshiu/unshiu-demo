require File.dirname(__FILE__) + '/../../test_helper'

module Manage
  module DiaEntryControllerTestModule
    
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
  
    define_method('test: 日記記事管理ページを表示する') do 
      login_as :quentin
    
      post :index
      assert_response :success
      assert_template 'list'
    end
  
    define_method('test: 日記記事一覧を表示する') do 
      login_as :quentin
    
      post :list
      assert_response :success
      assert_template 'list'
    end
  
    define_method('test: 日記記事を検索する') do 
      login_as :quentin
    
      post :search
      assert_response :success
      assert_template 'list'
    end
  
    define_method('test: 日記記事をキーワードで検索する') do 
      login_as :quentin
    
      post :search, :keyword => '日記'
      assert_response :success
      assert_template 'list'
    end
  
    define_method('test: 日記記事個別を表示する') do 
      login_as :quentin
    
      post :show, :id => 1
      assert_response :success
      assert_template 'show'
    end
  
    define_method('test: 日記記事削除確認画面を表示する') do 
      login_as :quentin
    
      post :delete_confirm, :id => 1
      assert_response :success
      assert_template 'delete_confirm'
    end
  
    define_method('test: 日記記事削除を実行する') do 
      login_as :quentin
    
      post :delete, :id => 1
      assert_response :redirect 
      assert_redirected_to :action => 'list'
    
      dia_entry = DiaEntry.find_by_id(1)
      assert_nil dia_entry # 削除されている
    end
  
    define_method('test: 日記記事削除を実行のキャンセル') do 
      login_as :quentin
    
      post :delete, :id => 1, :cancel => 'true'
      assert_response :redirect 
      assert_redirected_to :action => 'show'
    end
  end
end