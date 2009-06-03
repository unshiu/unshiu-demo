require "#{File.dirname(__FILE__)}/../test_helper"

module CmmAdminControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
        fixtures :base_mail_dispatch_infos
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 参加申請を承認しようとするが、既に処理済みなのでエラー画面へ遷移する') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm_admin/approve_confirm", :id => 1, :state => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03001"
  end
  
  define_method('test: 参加申請を承認実行しようとするが、既に処理済みなのでエラー画面へ遷移する') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm_admin/approve_complete", :id => 1, :state => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03002"
  end
  
  define_method('test: メンバーのステータスを変更しようとするが、メンバーをアクセス拒否と脱退しか許可してないのでエラー画面へ遷移する') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm_admin/member_status_confirm", :id => 1, :state => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03003"
  end
  
  define_method('test: メンバーのステータスを変更しようとするが、自分自身の権限は変更できないのでエラー画面へ遷移する') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm_admin/member_status_confirm", :id => 1, :state => 100
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03004"
  end
  
  define_method('test: メンバーのステータスを変更実行しようとするが、メンバーをアクセス拒否と脱退しか許可してないのでエラー画面へ遷移する') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm_admin/member_status_complete", :id => 1, :state => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03003"
  end
  
  define_method('test: メンバーのステータスを変更実行しようとするが、自分自身の権限は変更できないのでエラー画面へ遷移する') do
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "cmm_admin/member_status_complete", :id => 1, :state => 100
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03005"
  end
  
  define_method('test: メンバーのリストをみようとするが管理者ではないのでエラー画面へ遷移する') do
     post "base_user/login", :login => "five", :password => "test"

     post "cmm_admin/member_list", :id => 1, :state => 1
     assert_response :redirect
     assert_redirected_to :action => 'error'

     follow_redirect!

     assert_equal assigns(:error_code), "U-03006"
  end
  
  
  define_method('test: 参加申請を承認しようとするが、コミュニティ運用者ではないのででエラー画面へ遷移する') do
    post "base_user/login", :login => "ten", :password => "test"
    
    post "cmm_admin/approve_confirm", :id => 1, :state => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03007"
  end
  
  define_method('test: コミュニティ情報の変更をしようとするが、管理者かサブ管理者でないのでエラー画面へ遷移する') do
    post "base_user/login", :login => "ten", :password => "test"
    
    post "cmm_admin/edit", :id => 1, :state => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-03008"
  end
end