require File.dirname(__FILE__) + '/../../../../../../lib/string_expanse.rb'

module Manage::BaseNgWordControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_ng_words
        fixtures :base_user_roles
      end
    end
  end
 
  define_method('test: NGワード管理画面トップページを表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'list'
  end

  define_method('test: NGワード一覧を表示する') do 
    login_as :quentin
  
    post :list
    assert_response :success
    assert_template 'list'
  end

  define_method('test: NGワード新規登録画面を表示する') do 
    login_as :quentin
  
    post :new
    assert_response :success
    assert_template 'new'
  end

  define_method('test: NGワード確認画面を表示する') do 
    login_as :quentin
  
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: NGワード新規登録確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :ng_word => { :word => '登録されたらダメな単語', :active_flag => 'true'}
    assert_response :success
    assert_template 'confirm'
  end

  define_method('test: NGワード新規登録確認画面を表示しようとするが、wordが空欄なので入力画面を表示') do 
    login_as :quentin
  
    post :confirm, :ng_word => { :word => '', :active_flag => 'true'}
    assert_response :success
    assert_template 'new'
  end

  define_method('test: NGワード新規登録確認画面を表示しようとするが、既に登録済みなので入力画面を表示') do 
    login_as :quentin
  
    post :confirm, :ng_word => { :word => 'aaa', :active_flag => 'true'}
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: NGワード新規登録実行') do 
    login_as :quentin
  
    post :create, :ng_word => { :word => '登録されたらダメな単語', :active_flag => 'true'}
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  
    base_ng_word = BaseNgWord.find(:first, :conditions => [ " word = '登録されたらダメな単語' "])
    assert_not_nil(base_ng_word) # 単語が登録されている
    assert_equal(base_ng_word.active_flag, true)
  end

  define_method('test: NGワード新規登録実行する際、単語前後に空白があったので削除して登録する') do 
    login_as :quentin
  
    post :create, :ng_word => { :word => "　登録されたらダメな単語　", :active_flag => 'true'}
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  
    base_ng_word = BaseNgWord.find(:first, :conditions => [ " word = '登録されたらダメな単語' "])
    assert_not_nil(base_ng_word) # 単語が登録されている
    assert_equal(base_ng_word.active_flag, true)
  end
  
  define_method('test: NGワード新規登録実行をキャンセル') do 
    login_as :quentin
  
    post :create, :ng_word => { :word => '登録されたらダメな単語', :active_flag => 'true'}, :cancel => 'true'
    assert_response :success
    assert_template 'new'
  
    base_ng_word = BaseNgWord.find(:first, :conditions => [ " word = '登録されたらダメな単語' "])
    assert_nil(base_ng_word) # キャンセルしたので単語は登録されていない
  end

  define_method('test: NGワード編集画面を表示する') do 
    login_as :quentin
  
    post :edit, :id => 1 # base_ng_word = 1 を編集する
    assert_response :success
    assert_template 'edit'
  end

  define_method('test: NGワード編集確認画面を表示する') do 
    login_as :quentin
  
    post :update_confirm, :id => 1, :ng_word => { :word => '単語更新', :active_flag => 'false'}
    assert_response :success
    assert_template 'update_confirm'
    
    base_ng_word = BaseNgWord.find(:first, :conditions => [ " word = '単語更新' "])
    assert_nil(base_ng_word) # 確認画面なので単語は登録されていない
  end

  # 単純にユニークチェックをするとはじかれる。それが再現しないか確認
  define_method('test: NGワード編集確認画面で文言を修正せずに確認ボタンを押した場合に確認画面を表示する') do 
    login_as :quentin
  
    post :update_confirm, :id => 1, :ng_word => { :word => 'aaa', :active_flag => 'false'}
    assert_response :success
    assert_template 'update_confirm'
  end
  
  define_method('test: NGワード編集確認画面を表示しようとするがword欄が空欄なので登録画面へ戻る') do 
    login_as :quentin
  
    post :update_confirm, :id => 1, :ng_word => { :word => '', :active_flag => 'false'}
    assert_response :success
    assert_template 'edit'
  end

  define_method('test: NGワード編集処理実行') do 
    login_as :quentin
  
    post :update, :id => 1, :ng_word => { :word => '単語更新', :active_flag => 'false'}
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  
    base_ng_word = BaseNgWord.find_by_id(1)
    assert_not_nil(base_ng_word) 
    assert_equal(base_ng_word.word, '単語更新')
  end

  define_method('test: NGワード編集処理実行をキャンセル') do 
    login_as :quentin
  
    post :update, :id => 1, :ng_word => { :word => '単語更新', :active_flag => 'false'}, :cancel => 'true'
    assert_response :success
    assert_template 'edit'
  
    base_ng_word = BaseNgWord.find_by_id(1)
    assert_not_nil(base_ng_word) 
    assert_equal(base_ng_word.word, 'aaa') # cancelされているので変更されてない
  end

  define_method('test: NGワード削除確認画面を表示') do 
    login_as :quentin
  
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm'
  end

  define_method('test: NGワード削除処理を実行する') do 
    login_as :quentin
  
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  
    base_ng_word = BaseNgWord.find_by_id(1)
    assert_nil(base_ng_word) # 削除されている
  end

  define_method('test: NGワード削除処理実行のキャンセル') do 
    login_as :quentin
  
    post :delete, :id => 1, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'show', :id => 1
  
    base_ng_word = BaseNgWord.find_by_id(1)
    assert_not_nil(base_ng_word) # 削除されていない
  end
  
end