require File.dirname(__FILE__) + '/../../test_helper'

module ManagePntMasterControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :pnt_history_summaries
      end
    end
  end

  define_method('test: ポイントマスタ新規登録画面') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: ポイントマスタ新規登録確認画面') do 
    login_as :quentin
    
    post :confirm, :pnt_master => {:title => 'テストマスタ'}
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: ポイントマスタ新規登録でタイトルを未記入で登録した場合') do 
    login_as :quentin
    
    post :confirm, :pnt_master => {:title => ''}
    assert_response :success
    assert_template 'new' # 新規登録画面へ戻される
  end
  
  define_method('test: ポイントマスタ新規登録処理') do 
    login_as :quentin
    
    before_count = PntMaster.count
    
    post :create, :pnt_master => {:title => 'テストマスタ'}
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    after_count = PntMaster.count
    
    assert_equal before_count+1, after_count # 1件増えている
  end
  
  define_method('test: ポイントマスタ新規登録に失敗した場合') do 
    login_as :quentin
    
    post :create, :pnt_master => {:title => ''} # タイトルが未記入
    assert_response :redirect
    assert_redirected_to :action => 'new' # 新規登録画面へリダイレクト
  end
  
  define_method('test: ポイントマスタ編集画面を表示') do 
    login_as :quentin
    
    post :edit, :id => 1
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: ポイントマスタ編集確認画面を表示') do 
    login_as :quentin
    
    post :update_confirm, :pnt_master => { :id => 1, :title => 'ポイントマスタタイトル変更！' }
    assert_response :success
    assert_template 'update_confirm'
  end
  
  define_method('test: ポイントマスタ編集確認画面はタイトルが不正なため表示できない') do 
    login_as :quentin
    
    post :update_confirm, :pnt_master => { :id => 1, :title => '' }
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: ポイントマスタ編集実行処理') do 
    login_as :quentin
    
    before_count = PntMaster.count(:conditions => ['title = ?', "ポイントマスタタイトル変更!!"])
    assert_same(before_count, 0) # 事前チェック->そんなタイトルではない
    
    post :update, :pnt_master => { :id => 1, :title => 'ポイントマスタタイトル変更!!' }
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    after_count = PntMaster.count(:conditions => ['title = ?', "ポイントマスタタイトル変更!!"])
    assert_same(after_count, 1) # 変更されている
  end
  
  define_method('test: ポイントマスタ編集がタイトル不正のため実行されない') do 
    login_as :quentin
    
    post :update, :pnt_master => { :id => 1, :title => '' }
    assert_response :redirect
    assert_redirected_to :action => 'edit'
    
    after_count = PntMaster.count(:conditions => ['title = ?', ""])
    assert_same(after_count, 0) # 変更されていない
  end
  
  define_method('test: ポイントマスタ一覧表示') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: ポイントマスタ詳細表示') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: ポイントマスタ削除') do 
    login_as :quentin
    
    post :delete_confirm, :id => 4
    assert_response :success
    assert_template 'delete_confirm'
  end
  
  define_method('test: ポイントマスタ削除しようとするとが、関連履歴があるのでエラーページを表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ポイントマスタ削除実行') do 
    login_as :quentin
    
    post :delete, :pnt_master => { :id => 4 }
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    master = PntMaster.find_by_id(4)
    assert_nil master # 削除されている
  end
  
  define_method('test: ポイントマスタ削除実行しようとするが、関連履歴があるのでエラーページを表示する') do 
    login_as :quentin
    
    post :delete, :pnt_master => { :id => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    master = PntMaster.find_by_id(1)
    assert_not_nil master # 削除されていない
  end
end
