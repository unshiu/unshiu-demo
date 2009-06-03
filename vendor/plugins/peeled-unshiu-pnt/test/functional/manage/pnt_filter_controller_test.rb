require File.dirname(__FILE__) + '/../../test_helper'

module ManagePntFilterControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :pnt_masters
        fixtures :pnt_filters
        fixtures :pnt_filter_masters
        fixtures :pnt_points
        fixtures :pnt_history_summaries
      end
    end
  end
  
  define_method('test: ポイントフィルター新規作成画面を表示する') do 
    login_as :quentin
    
    post :new, :pnt_master_id => 1
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: ポイントフィルター新規作成の確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :pnt_filter => { :pnt_master_id => 1, 
                                    :point => 10, 
                                    :summary => 'ポイントフィルター新規作成の確認画面を表示する',
                                    :pnt_filter_master_id => 1 }
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: 期間限定のポイントフィルター新規作成の確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :pnt_filter => { :pnt_master_id => 1, 
                                    :point => 10, 
                                    :summary => 'ポイントフィルター新規作成の確認画面を表示する',
                                    :pnt_filter_master_id => 1, 
                                    :start_at => '2000-01-01 00:00:00', 
                                    :end_at => '2100-01-01 00:00:00' }
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: 配布回数限度ありなポイントフィルター新規作成の確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :pnt_filter => { :pnt_master_id => 1, 
                                    :point => 10, 
                                    :summary => 'ポイントフィルター新規作成の確認画面を表示する',
                                    :pnt_filter_master_id => 1, 
                                    :rule_day => 1, 
                                    :rule_count => 3 } # 1日に一人３回まで
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: ポイントフィルター新規作成をするが、要約が未入力のため新規画面へ戻される') do 
    login_as :quentin
    
    post :confirm, :pnt_filter => { :pnt_master_id => 1, 
                                    :point => 10, 
                                    :summary => '',
                                    :pnt_filter_master_id => 1 }
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: ポイントフィルターの新規作成実行をする') do 
    login_as :quentin
    
    pnt_filter = PntFilter.find(:first, :conditions => [' summary = ? ', 'ポイントフィルター新規作成の確認画面を表示する'])
    assert_nil pnt_filter # 事前チェック作成されてない
    
    post :create, :pnt_filter => { :pnt_master_id => 1, 
                                   :point => 10, 
                                   :summary => 'ポイントフィルター新規作成の確認画面を表示する',
                                   :pnt_filter_master_id => 1 }
    assert_response :redirect
    assert_redirected_to :controller => 'manage/pnt_master', :action => 'show', :id => 1 # 作成後はポイントマスタページへ
    
    pnt_filter = PntFilter.find(:first, :conditions => [' summary = ? ', 'ポイントフィルター新規作成の確認画面を表示する'])
    assert_not_nil pnt_filter # 作成済み
  end
  
  define_method('test: ポイントフィルターの新規作成実行をするがポイント値が数字じゃなかったのでエラーとなる') do 
    login_as :quentin
    
    post :create, :pnt_filter => { :pnt_master_id => 1, 
                                   :point => 'not number', 
                                   :summary => 'ポイントフィルターの新規作成実行をするがポイント値が数字じゃなかったのでエラーとなる',
                                   :pnt_filter_master_id => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'new' # 新規登録画面へ
    
    pnt_filter = PntFilter.find(:first, :conditions => [' summary = ? ', 'ポイントフィルターの新規作成実行をするがポイント値が数字じゃなかったのでエラーとなる'])
    assert_nil pnt_filter # 作成されてない
  end
  
  define_method('test: ポイントフィルター詳細表示') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: ポイントフィルター編集画面表示') do 
    login_as :quentin
    
    post :edit, :id => 1
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: ポイントフィルター編集確認画面表示') do 
    login_as :quentin
    
    post :update_confirm, :pnt_filter => { :pnt_master_id => 1, 
                                           :point => 10, 
                                           :summary => 'ポイントフィルター編集確認画面表示',
                                           :pnt_filter_master_id => 1 }
    assert_response :success
    assert_template 'update_confirm'
  end
  
  define_method('test: ポイントフィルター編集確認画面を表示しようとするが、サマリの値がないので編集画面へ戻る') do 
    login_as :quentin
    
    post :update_confirm, :pnt_filter => { :pnt_master_id => 1, 
                                           :point => 10, 
                                           :summary => '',
                                           :pnt_filter_master_id => 1 }
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: ポイントフィルター更新の実処理をする') do 
    login_as :quentin
    
    post :update, :pnt_filter => { :id => 1,
                                   :pnt_master_id => 1, 
                                   :point => 10, 
                                   :summary => 'ポイントフィルター更新の実処理をする',
                                   :pnt_filter_master_id => 1 }

    assert_response :redirect
    assert_redirected_to :controller => 'manage/pnt_master', :action => 'show', :id => 1 # 更新後はポイントマスタページ
                                       
    pnt_filter = PntFilter.find(1)
    assert_not_nil pnt_filter 
    assert_equal pnt_filter.summary, 'ポイントフィルター更新の実処理をする'
  end
  
  define_method('test: ポイントフィルター更新の実処理をするがポイントが文字列なので更新できずにエラーとなる') do 
    login_as :quentin
    
    post :update, :pnt_filter => { :id => 1,
                                   :pnt_master_id => 1, 
                                   :point => 'not number', 
                                   :summary => 'ポイントフィルター更新の実処理をするがポイントが文字列なので更新できずにエラーとなる',
                                   :pnt_filter_master_id => 1 }

    assert_response :redirect
    assert_redirected_to :action => 'edit' # 編集ページへもどる
                                       
    pnt_filter = PntFilter.find(1)
    assert_not_nil pnt_filter 
    assert_not_equal pnt_filter.summary, 'ポイントフィルター更新の実処理をするがポイントが文字列なので更新できずにエラーとなる' # 更新されてない
  end
  
  define_method('test: ポイントフィルター削除の確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1

    assert_response :success
    assert_template 'delete_confirm'
  end
  
  define_method('test: ポイントフィルター削除を実行する') do 
    login_as :quentin
    
    post :delete, :pnt_filter => { :id => 1 }

    assert_response :redirect
    assert_redirected_to :controller => 'manage/pnt_master', :action => 'show', :id => 1 # 削除後はポイントマスタページ
    
    pnt_filter = PntFilter.find_by_id(1)
    assert_nil pnt_filter # 削除されている
  end
end
