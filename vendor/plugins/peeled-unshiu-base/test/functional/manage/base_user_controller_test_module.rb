require "#{RAILS_ROOT}/lib/workers/base_user_file_generate_worker"

module Manage::BaseUserControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_profiles
        fixtures :base_friends
        fixtures :base_favorites
        fixtures :base_carriers
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :cmm_communities_base_users
        fixtures :cmm_communities
        fixtures :abm_albums
        fixtures :abm_image_comments
        fixtures :prf_profiles
        fixtures :prf_answers
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :base_user_file_histories
      end
    end
  end

  define_method('test: ユーザ管理トップ画面を表示') do 
    login_as :quentin
  
    post :index
    assert_response :redirect 
    assert_redirected_to :action => 'info'
  end

  define_method('test: ユーザ情報表示画面を表示') do 
    login_as :quentin
  
    post :info
    assert_response :success
    assert_template 'info'
  end

  define_method('test: ユーザ男女比率タブを表示') do 
    login_as :quentin
  
    post :sex_graph_tab
    assert_response :success
  end
  
  define_method('test: ユーザ男女比率グラフを表示') do 
    login_as :quentin
  
    post :sex_graph
    assert_response :success
  end

  define_method('test: メルマガ配信許可比率タブを表示') do 
    login_as :quentin
  
    post :mail_magazine_graph_tab
    assert_response :success
  end
  
  define_method('test: メルマガ配信許可比率を表示') do 
    login_as :quentin
  
    post :mail_magazine_graph
    assert_response :success
  end

  define_method('test: 既婚、未婚比率タブを表示') do 
    login_as :quentin
  
    post :civil_graph_tab
    assert_response :success
  end

  define_method('test: 既婚、未婚比率を表示') do 
    login_as :quentin
  
    post :civil_graph
    assert_response :success
  end

  define_method('test: 機種比率タブを表示') do 
    login_as :quentin
  
    post :carrier_graph_tab
    assert_response :success
  end

  define_method('test: 機種比率を表示') do 
    login_as :quentin
  
    post :carrier_graph
    assert_response :success
  end
  
  define_method('test: ユーザ検索画面を表示する') do 
    login_as :quentin
  
    post :search
    assert_response :success
    assert_template 'search'
  end

  define_method('test: ユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 保持ポイントを条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "0", :end_point => "1000" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 参加開始日付を条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => "2008", "date(2i)" => "01", "date(3i)" => "01" },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 参加開始、終了日付を条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => "2008", "date(2i)" => "01", "date(3i)" => "01" },
                       :joined_end_at => { "date(1i)" => "2008", "date(2i)" => "01", "date(3i)" => "02" },
                       :age => { :start => nil, :end => nil }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 年齢開始を条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => "10", :end => nil }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 年齢開始,終了を条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at =>   {"date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => "10", :end => "100" }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 地域情報を条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil },
                       :area => { "1" => true }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 未婚、既婚を条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil },
                       :civil_status => { "1" => true }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: 携帯キャリアを条件に加えてユーザ検索処理をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at =>   { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil },
                       :base_carrier_id => { "1" => true }
    assert_response :success
    assert_template 'list'
  end

  define_method('test: ポイントマスタが作成されていないため、ポイント情報がリクエストにはないが正常に検索をする') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil },
                       :base_carrier_id => { "1" => true }
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: 年齢が数字ではない値だったので検索画面を表示する') do 
    login_as :quentin
  
    post :user_search, :user => { :login => nil, :email => nil },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => "abc", :end => nil },
                       :base_carrier_id => { "1" => true }
    assert_response :success
    assert_template 'search'
  end
  
  define_method('test: ユーザ検索処理をし結果をcsvに出力する') do 
    login_as :quentin
  
    Manage::BaseUserController.stubs(:start_csv_output).returns("nil")
    
    before_all_count = BaseUserFileHistory.count(:all)
    
    post :user_search, :user => { :login => nil, :email => nil },
                       :pnt_master => { :id => 1 }, :point => { :start_point => "", :end_point => "" },
                       :joined_start_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :joined_end_at => { "date(1i)" => nil, "date(2i)" => nil, "date(3i)" => nil },
                       :age => { :start => nil, :end => nil },
                       :csv => true
                       
    assert_response :redirect 
    assert_redirected_to :action => 'search'
    assert_equal "CSVファイルの更新を開始しました。", flash[:notice]
    
    after_all_count = BaseUserFileHistory.count(:all)
    assert_equal(after_all_count, before_all_count + 1) # 1レコード増えている 
  end
  
  define_method('test: ユーザ情報個別表示画面を表示') do 
    login_as :quentin
  
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end

  define_method('test: 退会したユーザ情報個別表示画面を表示') do 
    login_as :quentin
  
    post :show, :id => 14 
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: ユーザ情報個別編集画面を表示') do 
    login_as :quentin
  
    post :edit, :id => 1
    assert_response :success
    assert_template 'edit'
  end

  define_method('test: ユーザ情報個別編集確認画面を表示') do 
    login_as :quentin
  
    post :update_confirm, :id => 1, :base_user => { :email => 'aaaaa@drecom.co.jp'}
    assert_response :success
    assert_template 'update_confirm'
  end
  
  define_method('test: ユーザ情報個別編集確認画面を表示しようとするが、更新内容に問題があるため入力画面へ遷移') do 
    login_as :quentin
  
    post :update_confirm, :id => 1, :base_user => { :email => ''}
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: ユーザ情報個別編集処理を実行する') do 
    login_as :quentin
  
    post :update, :id => 1, :base_user => { :email => 'aaaaa@drecom.co.jp'}
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    base_user = BaseUser.find_by_id(1)
    assert_not_nil(base_user)
    assert_equal(base_user.email, 'aaaaa@drecom.co.jp')
  end
  
  define_method('test: update はキャンセルボタンを押されると入力画面を表示する') do 
    login_as :quentin
  
    post :update, :id => 1, :base_user => { :email => ''}, :cancel => "true"
    assert_response :success 
    assert_template 'edit'
  end
  
  define_method('test: 強制退会の確認画面を表示する') do 
    login_as :quentin
  
    post :withdrawal_confirm, :id => 1
    assert_response :success
    assert_template 'withdrawal_confirm'
  end

  define_method('test: 強制退会の確認画面を表示しようとするが、唯一の管理者を退会させようとしているので検索画面へ戻る') do 
    BaseUserRole.delete(1) # あらかじめ削除
    login_as :aaron
  
    post :withdrawal_confirm, :id => 2
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  end
  
  define_method('test: 強制退会処理を実行する') do 
    login_as :quentin
  
    post :withdrawal, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    base_user = BaseUser.find(:first, :conditions => [' id = 1 '], :with_deleted => true)
    assert_not_nil(base_user)
    assert_not_nil(base_user.deleted_at) # 論理削除はされている
    assert_equal(base_user.status, BaseUser::STATUS_FORCED_WITHDRAWAL)
  end

  define_method('test: 強制退会処理をキャンセル') do 
    login_as :quentin
  
    post :withdrawal, :id => 1, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    base_user = BaseUser.find(:first, :conditions => [' id = 1 '], :with_deleted => true)
    assert_not_nil(base_user)
    assert_nil(base_user.deleted_at) # キャンセルしたので論理削除はされていない
  end

  define_method('test: ログイン停止の確認画面を表示する') do 
    login_as :quentin
  
    post :forbid_confirm, :id => 1
    assert_response :success
    assert_template 'forbid_confirm'
  end
  
  
  define_method('test: ログイン停止の確認画面を表示しようとするが、唯一の管理者を停止にしようとしているので検索画面へ戻る') do 
    BaseUserRole.delete(1) # あらかじめ削除
    login_as :aaron

    post :forbid_confirm, :id => 2
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  end
    
  define_method('test: ログイン停止処理実行をする') do 
    login_as :quentin
  
    post :forbid, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    base_user = BaseUser.find_by_id(1)
    assert_equal(base_user.status, BaseUser::STATUS_FORBIDDEN)
  end

  define_method('test: ログイン停止処理実行のキャンセルをする') do 
    login_as :quentin
  
    post :forbid, :id => 1, :cancel => "true"
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    base_user = BaseUser.find_by_id(1)
    assert_not_equal(base_user.status, BaseUser::STATUS_FORBIDDEN) # キャンセルしたのでステータスは書き変わっていない
  end

  define_method('test: ログイン停止を解除の確認画面を表示する') do 
    login_as :quentin
  
    post :activate_confirm, :id => 1
    assert_response :success
    assert_template 'activate_confirm'
  end

  define_method('test: ログイン停止を解除を実行する') do 
    login_as :quentin
  
    # 事前チェック：ステータスはログイン禁止中
    before_base_user = BaseUser.find_by_id(6)
    assert_equal(before_base_user.status, BaseUser::STATUS_FORBIDDEN)
  
    post :activate, :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    base_user = BaseUser.find_by_id(6)
    assert_equal(base_user.status, BaseUser::STATUS_ACTIVE) # ステータスは有効になっている
  end

  define_method('test: ログイン停止を解除のキャンセル') do 
    login_as :quentin
  
    post :activate, :id => 6, :cancel => "true"
    assert_response :redirect 
    assert_redirected_to :action => 'show'
  
    base_user = BaseUser.find_by_id(6)
    assert_not_equal(base_user.status, BaseUser::STATUS_ACTIVE) # キャンセルされたのでステータスは有効になっていいない
  end
  
  define_method('test: アカウントの復活処理の確認をする') do 
    # 事前確認：退会しているか
    base_user = BaseUser.find(:first, :conditions => [' id = 8 '], :with_deleted => true)
    assert_not_nil(base_user)
    assert_not_nil(base_user.deleted_at) # 論理削除済み
    
    login_as :quentin
  
    post :restore_confirm, :id => 8
    assert_response :success
    assert_template 'restore_confirm'
  end
  
  define_method('test: restore はアカウントの復活処理を実行する') do
    login_as :quentin
  
    post :restore, :id => 8
    assert_response :redirect 
    assert_redirected_to :action => 'show'
    
    base_user = BaseUser.find_by_id(8)
    
    assert_not_nil(base_user)
    assert_equal(base_user.status, BaseUser::STATUS_ACTIVE) # ステータスが有効に
    
    assert_not_nil(base_user.base_profile) # dependent で消えていたものも復活
  end

  define_method('test: アカウントの復活処理をキャンセルしアカウント表示画面に戻る') do
    login_as :quentin
  
    post :restore, :id => 8, :cancel => true
    assert_response :redirect 
    assert_redirected_to :action => 'show'
    
    base_user = BaseUser.find_with_deleted(8)
    assert_not_nil(base_user.deleted_at) # 削除日付はそのまま
    assert_not_equal(base_user.status, BaseUser::STATUS_ACTIVE) # ステータスは有効でない
  end
  
end