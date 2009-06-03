require File.dirname(__FILE__) + '/../../test_helper'

module ManagePntControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :pnt_histories
        fixtures :pnt_history_summaries
      end
    end
  end
  
  define_method('test: ユーザのポイント履歴を表示する') do 
    login_as :quentin
    
    post :user_history, :id => 1
    assert_response :success
    assert_template 'user_history'
  end
  
  define_method('test: 退会したユーザのポイント履歴を表示する') do 
    login_as :quentin
    
    post :user_history, :id => 8
    assert_response :success
    assert_template 'user_history'
  end
  
  define_method('test: ポイント履歴がまだないユーザのポイント履歴ページを表示する') do 
    login_as :quentin
    
    post :user_history, :id => 10
    assert_response :success
    assert_template 'user_history'
  end
  
  define_method('test: ポイント履歴をユーザに配布する確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :pnt_history => {:pnt_point_id => 1, :difference => 10, :message => 'test'}, 
                   :pnt_master => {:id => 1}, 
                   :base_user => {:id => 1}
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: ポイント履歴をユーザに配布する確認画面を表示するがポイント情報が不正') do 
    login_as :quentin
    
    post :confirm, :pnt_history => {:pnt_point_id => 1, :difference => 'error', :message => 'test'}, 
                   :pnt_master => {:id => 1}, 
                   :base_user => {:id => 1}
    assert_response :success
    assert_template 'user_history' #履歴画面へ戻る
  end
  
  define_method('test: ポイント履歴をユーザに配布する') do 
    login_as :quentin
    
    post :create, :pnt_history => {:pnt_point_id => 1, :difference => 20, :message => 'test: ポイント履歴をユーザに配布する'}, 
                   :pnt_master => {:id => 1}, 
                   :base_user => {:id => 1}
    assert_response :redirect
    assert_redirected_to :action => 'user_history', :id => 1 # 履歴画面へ戻る
    
    # ポイント増加処理がおこなわれているか
    pnt_point = PntPoint.find_base_user_point(1, 1)
    assert_equal pnt_point.point, 120
    
    # 履歴が残っているか 
    pnt_history = PntHistory.find(:first, :conditions => ["message = 'test: ポイント履歴をユーザに配布する'"])
    assert_not_nil pnt_history
    assert_equal pnt_history.amount, 120
  end
  
  define_method('test: ポイント履歴をユーザに配布するが0ポイント以下になるので処理不可能') do 
    login_as :quentin
    
    post :create, :pnt_history => {:pnt_point_id => 1, :difference => -1000, :message => 'test: ポイント履歴をユーザに配布するが0ポイント以下になるので処理不可能'}, 
                   :pnt_master => {:id => 1}, 
                   :base_user => {:id => 1}
    assert_response :redirect
    assert_redirected_to :action => 'user_history', :id => 1 # 履歴画面へ戻る
    
    # ポイント増加処理がおこなわれていないか
    pnt_point = PntPoint.find_base_user_point(1, 1)
    assert_equal pnt_point.point, 100
    
    # 履歴が残っていないか
    pnt_history = PntHistory.find(:first, :conditions => ['pnt_point_id = 1'], :order => 'created_at desc')
    assert_not_equal pnt_history.message, 'test: ポイント履歴をユーザに配布するが0ポイント以下になるので処理不可能'
  end
  
  define_method('test: ポイント履歴をユーザに配布する境界値テスト') do 
    login_as :quentin
    
    post :create, :pnt_history => {:pnt_point_id => 1, :difference => -101, :message => 'test: ポイント履歴をユーザに配布する境界値テスト'}, 
                   :pnt_master => {:id => 1}, 
                   :base_user => {:id => 1}
    assert_response :redirect
    assert_redirected_to :action => 'user_history', :id => 1 # 履歴画面へ戻る
    
    # ポイント増加処理は可能限界を超えているので不可
    pnt_point = PntPoint.find_base_user_point(1, 1)
    assert_equal pnt_point.point, 100
    
    # 履歴が残っていないか
    pnt_history = PntHistory.find(:first, :conditions => ['pnt_point_id = 1'], :order => 'created_at desc')
    assert_not_equal pnt_history.message, 'test: ポイント履歴をユーザに配布する境界値テスト'
  end
  
  define_method('test: ポイント履歴をユーザに配布する境界値テスト') do 
    login_as :quentin
    
    post :create, :pnt_history => {:pnt_point_id => 1, :difference => -100, :message => 'test: ポイント履歴をユーザに配布する境界値テスト'}, 
                   :pnt_master => {:id => 1}, 
                   :base_user => {:id => 1}
    assert_response :redirect
    assert_redirected_to :action => 'user_history', :id => 1 # 履歴画面へ戻る
    
    # ポイント増加処理は可能限界値なので平気
    pnt_point = PntPoint.find_base_user_point(1, 1)
    assert_equal pnt_point.point, 0
    
    # 履歴が残っているか
    pnt_history = PntHistory.find(:first, :conditions => ["message = 'test: ポイント履歴をユーザに配布する境界値テスト'"])
    assert_not_nil pnt_history
    assert_equal pnt_history.difference, -100
    assert_equal pnt_history.amount, 0
  end
  
  define_method('test: 月別履歴を参照するテスト') do 
    login_as :quentin
    
    post :month_history
    assert_response :success
    assert_template 'month_history'
  end
  
  define_method('test: 月別履歴csvファイルをダウンロードするテスト') do
    # ダウンロード用のファイル作成
    summary = PntHistorySummary.find(1)
    
    file_dir = "#{RAILS_ROOT}/#{AppResources['pnt']['history_file_path']}"
    Dir::mkdir(file_dir) unless File.exist?(file_dir)
    
    file_name = "#{file_dir}/#{summary.file_name}"
    file = open(file_name, "w") 
    file.puts "月別履歴csvファイルをダウンロードするテスト"
    file.close
    
    begin
      login_as :quentin
      post :export, :id => 1
      assert_response :success
      
      # TODO: レスポンスのテストってどうやるのだろうか
    ensure # テスト用ファイルはなにがあっても消す
      File.delete(file_name)
    end
  end
end
