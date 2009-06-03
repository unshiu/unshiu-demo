require File.dirname(__FILE__) + '/../test_helper'

module CmmAdminControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
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

  define_method('test: 編集処理はログインしていないとできない') do
    login_required_test :edit_complete
  end
  
  define_method('test: 編集処理を実行する') do
    login_as :quentin
    
    before_cmm_community = CmmCommunity.find(1)
    before_cmm_community.name = "cmm_admin_controller_edit_complate"
    
    get :edit_complete, :id => 1, :community => before_cmm_community.attributes
    assert_response :redirect
    assert_redirected_to :controller => :cmm, :action => :show, :id => 1
    
    cmm_community = CmmCommunity.find(1)
    
    assert_equal before_cmm_community.id, cmm_community.id
    assert_equal cmm_community.name, "cmm_admin_controller_edit_complate"
  end
  
  define_method('test: validationに問題がある場合は編集処理を実行せず編集画面に戻る') do
    login_as :quentin
    
    get :edit_complete, :id => 1, :community => CmmCommunity.new.attributes
    
    assert_response :success
    assert_template "edit"
    
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
  
  define_method('test: コミュニティメンバー一覧はログインしていなと閲覧できない') do
    login_required_test :member_list
  end
  
  define_method('test: コミュニティメンバー一覧を表示する') do
    login_as :aaron
    
    get :member_list, :id => 1
    assert_response :success
  end
  
  define_method('test: コミュニティの一般メンバー一覧を表示する') do
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
  end
  
  define_method('test: コミュニティの副管理者ー一覧を表示する') do
    login_as :aaron
    
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
  
  define_method('test: approve_confirm はアクセス禁止メンバー承認確認画面を表示する') do
    login_as :aaron
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_REJECTED
    assert_response :success
    
    assert_equal CmmCommunitiesBaseUser::STATUS_REJECTED, assigns["state"]
    assert_instance_of CmmCommunitiesBaseUser, assigns["ccbu"]
  end
  
  define_method('test: approve_confirm はメンバー参加申請拒否確認画面を表示する') do
    login_as :aaron
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_NONE
    assert_response :success
    
    assert_equal CmmCommunitiesBaseUser::STATUS_NONE, assigns["state"]
    assert_instance_of CmmCommunitiesBaseUser, assigns["ccbu"]
  end

  define_method('test: approve_confirm は承認まちでないユーザを承認しようと確認画面を表示しようとするとエラー画面へ遷移する') do
    login_as :aaron
    
    get :approve_confirm, :id => 1, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :redirect
    assert_redirect_with_error_code "U-03001"
  end
  
  define_method('test: approve_confirm は管理者以外がユーザを承認しようと確認画面を表示しようとするとエラー画面へ遷移する') do
    login_as :five
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end
  
  define_method('test: approve_confirm はサブ管理者も承認権限はないのでがユーザを承認しようと確認画面を表示しようとするとエラー画面へ遷移する') do
    login_as :quentin
    
    get :approve_confirm, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    assert_response :redirect
    assert_redirect_with_error_code "U-03007"
  end
  
  define_method('test: approve_complete はコミュニティ承認実行はログインしていないと実行できない') do
    login_required_test :approve_complete
  end
  
  define_method('test: approve_complete はコミュニティ承認実行できる') do
    login_as :aaron
    
    ccbu5 = CmmCommunitiesBaseUser.find(5)
    assert_equal CmmCommunitiesBaseUser::STATUS_APPLYING, ccbu5.status

    get :approve_complete, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER,
                           :return_to => "/cmm_admin/member_list/5?state=#{CmmCommunitiesBaseUser::STATUS_MEMBER}"
    assert_response :redirect
    assert_redirected_to :controller => :cmm_admin, :action => :member_list, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER
    
    ccbu5 = CmmCommunitiesBaseUser.find(5)
    
    assert_equal CmmCommunitiesBaseUser::STATUS_MEMBER, ccbu5.status
  end
  
  define_method('test: approve_complete はコミュニティ参加申請拒否を実行できる') do
    login_as :aaron
    
    get :approve_complete, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_NONE,
                           :return_to => "/cmm_admin/member_list/5?state=#{CmmCommunitiesBaseUser::STATUS_NONE}"
                           
    assert_response :redirect
    assert_redirected_to :controller => :cmm_admin, :action => :member_list, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_NONE
    
    ccbu5 = CmmCommunitiesBaseUser.find_by_id(5)
    assert_nil ccbu5 # 拒否したので関連がなくなっている
  end
  
  define_method('test: approve_complete はキャンセルボタンを押すとメンバーリストへ戻る') do
    login_as :aaron
    
    get :approve_complete, :id => 5, :state => CmmCommunitiesBaseUser::STATUS_MEMBER, :cancel => "cancel", 
                           :return_to => "/cmm_admin/member_list/5?state=5"
    
    assert_response :redirect
    assert_redirected_to :controller => :cmm_admin, :action => :member_list, :id => 5, :state => 5
    ccbu5 = CmmCommunitiesBaseUser.find 5
    # statusが変わってないことを確認
    assert_equal CmmCommunitiesBaseUser::STATUS_APPLYING, ccbu5.status
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
    assert_redirected_to :controller => :cmm_user, :action => :list
    
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
  
  define_method('test: コミュニティ画像設定画面を表示する') do
    login_as :aaron
    
    get :image, :id => 1
    
    assert_response :success
    assert_template "image"
  end
  
  define_method('test: コミュニティ画像設定画面をはコミュニティ管理者でなければ表示できない') do
    login_as :quentin
    
    get :image, :id => 1
    
    assert_response :redirect
    assert_redirect_with_error_code "U-03006"
  end
  
  define_method('test: コミュニティ画像アップロード処理を実行する') do
    login_as :aaron
    
    CmmImage.delete_all
    assert_nil(CmmCommunity.find(1).cmm_image)
    
    update_path = RAILS_ROOT + "/test/tmp/file_column/cmm_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    image = uploaded_file(file_path("file_column/cmm_image/image/3/logo.gif"), 'image/gif', 'logo.gif')
    
    post :image_upload, :upload_file => {:image => image}, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => :cmm, :action => :show, :id => 1
    
    assert_not_nil(CmmCommunity.find(1).cmm_image) # 画像が設定されている
    assert_equal(File.basename(CmmCommunity.find(1).cmm_image.image), "logo.gif")
  end
  
  define_method('test: コミュニティ画像アップロード処理を実行しようとするが制限以上の大きさだったのでアップロード画面へ戻る') do
    login_as :aaron
    
    CmmImage.delete_all
    
    update_path = RAILS_ROOT + "/test/tmp/file_column/cmm_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    image = uploaded_file(file_path("file_column/cmm_image/image/1/2545254646_374965b106.jpg"), 'image/jpg', '2545254646_374965b106.jpg')
    
    post :image_upload, :upload_file => {:image => image}, :id => 1
    assert_response :success
    assert_template "image"
    
    assert_nil(CmmCommunity.find(1).cmm_image) # 画像が設定されていない
  end
  
  define_method('test: image_upload はアップロードするファイルを選択されていなければアップロード画面へ戻る') do
    login_as :aaron
    
    post :image_upload, :upload_file => nil, :id => 1
    assert_response :success
    assert_template "image"
  end
  
  define_method('test: コミュニティ画像アップロード処理実行はコミュニティ管理者でなければ表示できない') do
    login_as :quentin
    
    update_path = RAILS_ROOT + "/test/tmp/file_column/cmm_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    image = uploaded_file(file_path("file_column/cmm_image/image/3/logo.gif"), 'image/gif', 'logo.gif')
    
    post :image_upload, :upload_file => {:image => image}, :id => 1
    
    assert_response :redirect
    assert_redirect_with_error_code "U-03006"
  end
  
private

  def login_required_test(action)    
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/cmm_admin/#{action}"
  end
end
