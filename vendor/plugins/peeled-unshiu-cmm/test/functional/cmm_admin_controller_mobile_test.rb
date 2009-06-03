require File.dirname(__FILE__) + '/../test_helper'

# FIXME 1テストの中で数回リクエストを投げているのはなし
module CmmAdminControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
        fixtures :base_mail_dispatch_infos
      end
    end
  end
  
  define_method('test: 編集入力画面はログインしていないと閲覧できない') do
    login_required_test :edit
  end

  define_method('test: 新規作成入力画面を表示する') do
    login_as :quentin
    
    get :edit, :id => 1
    assert_response :success
    
    assert_equal CmmCommunity.find(1).id, assigns["community"].id
  end

  define_method('test: 編集入力画面を表示する') do
    login_as :quentin
    
    community = CmmCommunity.find(2)
    
    get :edit, :id => 2, :community => community.attributes
    assert_response :success
    
    assert_equal CmmCommunity.find(2).id, assigns["community"].id
  end
  
  define_method('test: 編集確認画面はログインしていないと閲覧できない') do
    login_required_test :edit_confirm
  end
  
  define_method('test: 編集確認画面を表示する') do
    login_as :quentin

    community = CmmCommunity.find(1)
    
    get :edit_confirm, :id => 1, :community => community.attributes
    assert_response :success
    assert_template "edit_confirm_mobile"

    assert_equal community, assigns["community"]
  end

  define_method('test: 編集処理はログインしていないとできない') do
    login_required_test :edit_complete
  end
  
  define_method('test: 編集処理を実行する') do
    login_as :quentin
    
    before_cmm_community = CmmCommunity.find(1)
    before_cmm_community.name = "cmm_admin_controller_edit_complate"
    
    get :edit_complete, :id => 1, :community => before_cmm_community.attributes
    assert_response :redirect
    assert_redirected_to :action => :edit_done, :id => 1
    
    cmm_community = CmmCommunity.find(1)
    
    assert_equal before_cmm_community.id, cmm_community.id
    assert_equal cmm_community.name, "cmm_admin_controller_edit_complate"
  end
  
  define_method('test: validationに問題がある場合は編集処理を実行せず編集画面に戻る') do
    login_as :quentin
    
    get :edit_complete, :id => 1, :community => CmmCommunity.new.attributes
    
    assert_response :success
    assert_template "edit_mobile"
    
    assert_instance_of CmmCommunity, assigns["community"]
    
    cmm_community = CmmCommunity.find(1)
    assert_not_equal cmm_community.name, "" # 変更されてない
  end

  define_method('test: 編集処理はゲストユーザではできない') do
    login_as :three
    
    community = CmmCommunity.find(1)
    community.name = "NEW NAME"
    
    get :edit_complete, :id => 1, :community => community.attributes
    assert_response :redirect
    assert_redirect_with_error_code "U-03008"
  end
  
  define_method('test: 編集処理は承認待ちユーザではできない') do
    login_as :five
    
    community = CmmCommunity.find(1)
    community.name = "NEW NAME"
    
    get :edit_complete, :id => 1, :community => community.attributes
    assert_response :redirect
    assert_redirect_with_error_code "U-03008"
  end
  
  define_method('test: 編集処理はアクセス禁止ユーザではできない') do
    login_as :ten
    
    community = CmmCommunity.find(1)
    community.name = "NEW NAME"
    
    get :edit_complete, :id => 1, :community => community.attributes
    assert_response :redirect
    assert_redirect_with_error_code "U-03008"
  end
  
  define_method('test: 編集処理は一般メンバーユーザではできない') do
    login_as :four
    
    community = CmmCommunity.find(1)
    community.name = "NEW NAME"
    
    get :edit_complete, :id => 1, :community => community.attributes
    assert_response :redirect
    assert_redirect_with_error_code "U-03008"
  end
  
  define_method('test: 編集完了画面はログインしていないと閲覧できない') do
    login_required_test :edit_done
  end
  
  def test_edit_done
    login_as :quentin
    
    get :edit_done, :id => 1
    assert_response :success
    assert_template "edit_done_mobile"
    
    community = assigns["community"]
    
    assert_instance_of CmmCommunity, assigns["community"]
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: コミュニティ画像投稿メールアドレス表示画面はログインしていないと閲覧できない') do
    login_required_test :mail
  end
  
  define_method('test: コミュニティ画像投稿メールアドレス管理者じゃないと閲覧できない') do
    login_as :quentin
    
    get :mail, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code "U-03006"
  end
  
  def test_mail
    # Adminでチェック
    login_as :aaron
    get :mail, :id => 1
    assert_response :success
    community = assigns["community"]
    mail_address = mail_address = assigns["mail_address"]
    
    assert_instance_of CmmCommunity, community
    assert_equal CmmCommunity.find(1), community
    
    assert_equal "test5@test", mail_address
    
  end
  
  define_method('test: 承認確認画面はログインしていないと閲覧できない') do
    login_required_test :approve_confirm
  end
  
  define_method('test: 承認確認画面を表示する') do
    login_as :aaron
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :success
    
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, assigns["state"]
    assert_instance_of CmmCommunitiesBaseUser, assigns["ccbu"]
  end

  define_method('test: メンバー承認確認画面を表示する') do
    login_as :aaron
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :success
    
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, assigns["state"]
    assert_instance_of CmmCommunitiesBaseUser, assigns["ccbu"]
  end
  
  define_method('test: アクセス禁止メンバー承認確認画面を表示する') do
    login_as :aaron
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_REJECTED
    assert_response :success
    
    assert_equal CmmCommunitiesBaseUser::STATUS_REJECTED, assigns["state"]
    assert_instance_of CmmCommunitiesBaseUser, assigns["ccbu"]
  end
  
  define_method('test: メンバー参加申請拒否確認画面を表示する') do
    login_as :aaron
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_NONE
    assert_response :success
    
    assert_equal CmmCommunitiesBaseUser::STATUS_NONE, assigns["state"]
    assert_instance_of CmmCommunitiesBaseUser, assigns["ccbu"]
  end

  define_method('test: メンバ承認まちでないユーザを承認しようと確認画面を表示しようとするとエラー画面へ遷移する') do
    login_as :aaron
    
    get :approve_confirm, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :redirect
    assert_redirect_with_error_code "U-03001"
  end
  
  define_method('test: 管理者以外がユーザを承認しようと確認画面を表示しようとするとエラー画面へ遷移する') do
    login_as :five
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end
  
  define_method('test: サブ管理者も承認権限はないのでがユーザを承認しようと確認画面を表示しようとするとエラー画面へ遷移する') do
    login_as :quentin
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end
  
  define_method('test: コミュニティ承認実行はログインしていないと実行できない') do
    login_required_test :approve_complete
  end
  
  def test_approve_complete
    login_as :aaron
    
    ccbu5 = CmmCommunitiesBaseUser.find(5)
    assert_equal CmmCommunitiesBaseUser::STATUS_APPLYING, ccbu5.status

    get :approve_complete, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :redirect
    assert_redirected_to :action => :approve_done, :id => 1
    
    ccbu5 = CmmCommunitiesBaseUser.find(5)
    
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, ccbu5.status
  end
  
  define_method('test: コミュニティ参加申請拒否を実行する') do
    login_as :aaron
    
    get :approve_complete, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_NONE
    assert_response :redirect
    assert_redirected_to :action => :approve_done, :id => 1
    
    ccbu5 = CmmCommunitiesBaseUser.find_by_id(5)
    assert_nil ccbu5 # 拒否したので関連がなくなっている
  end
  
  def test_approve_complete_cancel
    login_as :aaron
    # cancelテスト
    get :approve_complete, 
        :id => 5, 
        :state => CmmCommunitiesBaseUser::STATUS_MEMBER, 
        :cancel => "cancel"
    
    assert_response :redirect
    assert_redirected_to :controller => :cmm, :action => :show, :id => 1
    ccbu5 = CmmCommunitiesBaseUser.find 5
    # statusが変わってないことを確認
    assert_equal CmmCommunitiesBaseUser::STATUS_APPLYING, ccbu5.status
  end
  
  define_method('test: 承認完了画面はログインしていないと閲覧できない') do
    login_required_test :approve_done
  end
  
  define_method('test: 承認完了画面を表示する') do
    login_as :quentin
    
    get :approve_done, :id => 1
    assert_response :success
    
    assert_instance_of CmmCommunity, assigns["community"]
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: コミュニティメンバー一覧を表示する') do
    login_as :aaron
    
    get :member_list, :id => 1
    assert_response :success
  end
  
  define_method('test: コミュニティメンバー一覧はログインしていなと閲覧できない') do
    login_required_test :member_list
  end
  
  def test_member_list
    # ADMINでログイン
    login_as :aaron
    get :member_list, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :success
    
    community = assigns["community"]
    members   = assigns["members"]
    state     = assigns["state"]
    
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, state
    
    assert_instance_of CmmCommunity, community
    assert_equal CmmCommunity.find(1), community
    
    assert_instance_of PagingEnumerator, members
    members.each do |member|
      assert_instance_of CmmCommunitiesBaseUser, member
      assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, member.status
    end
    
    
    # STATUS_SUBADMINを検索
    get :member_list, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_SUBADMIN
    assert_response :success
    
    community = assigns["community"]
    members   = assigns["members"]
    state     = assigns["state"]
    
    assert_equal CmmCommunitiesBaseUser::STATUS_SUBADMIN, state
    
    assert_instance_of CmmCommunity, community
    assert_equal CmmCommunity.find(1), community
    
    assert_instance_of PagingEnumerator, members
    members.each do |member|
      assert_instance_of CmmCommunitiesBaseUser, member
      assert_equal CmmCommunitiesBaseUser::STATUS_SUBADMIN, member.status
    end
    
  end
  
  define_method('test: メンバーステータス変更確認画面はログインしていないと閲覧できない') do
    login_required_test :member_status_confirm
  end
  
  define_method('test: 管理権限がなければステータス変更はできない') do
    login_as :quentin
    
    get :member_status_confirm, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_ADMIN
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end

  define_method('test: 自分の権限は変更できない') do
    login_as :aaron
    
    get :member_status_confirm, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_ADMIN
    assert_response :redirect
    assert_redirect_with_error_code "U-03003"
  end

  define_method('test: アクセス禁止へのメンバーのステータス変更からはステータス変更からはできない') do
    login_as :aaron
    
    get :member_status_confirm, :id => 2, :state => CmmCommunitiesBaseUser::STATUS_REJECTED
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end
  
  define_method('test: 削除のメンバーのステータス変更からはステータス変更からはできない') do
    login_as :aaron
    
    get :member_status_confirm, :id => 2, :state => CmmCommunitiesBaseUser::STATUS_NONE
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end
  
  def test_member_status_confirm
    #正常
    # FIXME
    # 仕様が未確定なので仕様を確定させてから再度テストを通るようにする
    #get :member_status_confirm, :id => @community_base_user2.id, :state => CmmCommunity::STATUS_ADMIN
    #assert_response :sccess
    #
    #state = assigns["state"]
    #ccbu  = assigns["ccbu"]
    
    #assert_equal CmmCommunity::STATUS_ADMIN, state
    #assert_instance_of CmmCommunitiesBaseUser, ccbu
    #assert_equal @community_base_user1, ccbu
  end
  
  define_method('test: コミュニティメンバーを脱退させる確認画面を表示する') do
    login_as :aaron
    
    get :member_status_confirm, :id => 3, :state => CmmCommunitiesBaseUser::STATUS_NONE # base_user_id = 3のユーザを脱退
    assert_response :success
    assert_template "member_status_confirm_mobile"
     
    assert_equal CmmCommunitiesBaseUser::STATUS_NONE, assigns["state"]
  end
  
  define_method('test: アクセス禁止にしたコミュニティメンバーのアクセス禁止を解除する確認画面を表示する') do
    login_as :aaron
    
    get :member_status_confirm, :id => 10, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :success
    assert_template "member_status_confirm_mobile"
     
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, assigns["state"]
  end
  
  define_method('test: アクセス禁止へのメンバステータス変更は管理者じゃないとできない') do
    login_as :quentin
    
    get :member_status_complete, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_REJECTED
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end

  define_method('test: コミュニティ管理者は自分をアクセス禁止するような権限の変更はできない') do
    login_as :aaron
    
    get :member_status_complete, :id => 2, :state => CmmCommunitiesBaseUser::STATUS_REJECTED
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end

  define_method('test: コミュニティスのテータス変更画面からは管理権限の変更はできない') do
    login_as :aaron
    
    get :member_status_complete, :id => 3, :state => CmmCommunitiesBaseUser::STATUS_ADMIN
    assert_response :redirect
    assert_redirect_with_error_code "U-03003"
  end
  
  define_method('test: コミュニティスのテータス変更画面からはサブ管理権限の変更はできない') do
    login_as :aaron
    
    get :member_status_complete, :id => 3, :state => CmmCommunitiesBaseUser::STATUS_SUBADMIN
    assert_response :redirect
    assert_redirect_with_error_code "U-03003"
  end
  
  define_method('test: アクセス禁止にしたコミュニティメンバーのアクセス禁止を解除を実行する') do
    login_as :aaron
    
    # cmm_communities_base_users id = 10 の ユーザ関連ののアクセス禁止を解除する
    get :member_status_complete, :id => 10, :state => CmmCommunitiesBaseUser::STATUS_MEMBER 
    assert_response :redirect
    assert_redirected_to :action => :member_status_done, :id => 1
    
    ccbu = CmmCommunitiesBaseUser.find 10
    
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, ccbu.status
  end
  
  define_method('test: アクセス禁止にしたコミュニティメンバーのアクセス禁止を解除のキャンセルをする') do
    login_as :aaron
    
    get :member_status_complete, :id => 10, :state => CmmCommunitiesBaseUser::STATUS_MEMBER, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :controller => :cmm_admin, :action => :member_list, :id => 1, :state => 100
    
    ccbu = CmmCommunitiesBaseUser.find 10
    
    assert_not_equal CmmCommunitiesBaseUser::STATUS_MEMBER, ccbu.status
  end
  
  define_method('test: メンバステータス変更はログインしていなとできない') do
    login_required_test :member_status_complete
  end
  
  define_method('test: アクセス禁止へのメンバステータス変更完をする') do
    login_as :aaron

    before_cmm_community_base_user = CmmCommunitiesBaseUser.find(3)
    
    get :member_status_complete, :id => 3, :state => CmmCommunitiesBaseUser::STATUS_REJECTED
    assert_response :redirect
    assert_redirected_to :action => :member_status_done, :id => 1
    
    cmm_community_base_user = CmmCommunitiesBaseUser.find(3)
    
    assert_not_equal before_cmm_community_base_user.status, cmm_community_base_user.status # 変更されている
    assert_equal CmmCommunitiesBaseUser::STATUS_REJECTED, cmm_community_base_user.status
  end
  
  define_method('test: 脱退へのメンバステータス変更完をする') do
    login_as :aaron

    get :member_status_complete, :id => 3, :state => CmmCommunitiesBaseUser::STATUS_NONE
    assert_response :redirect
    assert_redirected_to :action => :member_status_done, :id => 1
    
    cmm_community_base_user = CmmCommunitiesBaseUser.find_by_id(3)
    assert_nil(cmm_community_base_user) # 削除されている
  end
  
  define_method('test: メンバーステータス変更完了ページはログインしていないと閲覧できない') do
    login_required_test :member_status_done
  end
  
  define_method('test: メンバーステータス変更完了ページを表示する') do
    login_as :quentin
    
    get :member_status_done, :id => 1
    assert_response :success
    
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: コミュニティ削除確認画面はログインしていないと閲覧できない') do
    login_required_test :destroy_confirm
  end
  
  define_method('test: コミュニティ削除はサブ管理者ではできないので確認画面を表示しようとするとエラー') do
    login_as :quentin
    
    get :destroy_confirm, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code "U-03006"
  end
  
  define_method('test: 管理者はコミュニティ削除が可能なので確認画面を表示できる') do
    login_as :aaron
    
    get :destroy_confirm, :id => 1
    assert_response :success
    assert_equal CmmCommunity.find(1), assigns["community"]
  end
  
  define_method('test: 管理者でも権利権限のないはコミュニティ削除はできないのでエラー画面を表示する') do
    login_as :aaron
    
    get :destroy_confirm, :id => 2
    assert_response :redirect
    assert_redirect_with_error_code "U-03006"
  end
  
  define_method('test: コミュニティ削除実行はログインしていないとできない') do
    login_required_test :destroy_complete
  end
  
  define_method('test: コミュニティ削除実行をする') do
    login_as :aaron
    
    get :destroy_complete, :id => 1
    assert_response :redirect
    assert_redirected_to :action => :destroy_done
    
    assert_raise(ActiveRecord::RecordNotFound) do
      CmmCommunity.find(1)
    end
  end

  define_method('test: コミュニティ削除実行は管理者じゃないとできない') do
    login_as :quentin
    
    get :destroy_complete, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code "U-03006"
  end
    
  define_method('test: コミュニティ削除実行をキャンセルボタンをおして取りやめる') do
    login_as :aaron
    
    get :destroy_complete, :id => 1, :cancel => "cancel"
    
    assert_response :redirect
    assert_redirected_to :controller => :cmm, :action => :show, :id => 1
    
    assert_not_nil CmmCommunity.find_by_id(1) # 処理が行われていないことを確認
  end
  
  define_method('test: コミュニティ削除完了画面はログインしていないと閲覧できない') do
    login_required_test :destroy_done
  end
  
  define_method('test: コミュニティ削除完了画面を閲覧する') do
    login_as :quentin
    
    get :destroy_done
    assert_response :success
  end
  
private

  def login_required_test(action)    
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/cmm_admin/#{action}"
  end
end
