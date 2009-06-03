require File.dirname(__FILE__) + '/../../test_helper'

module ManageMngUserControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
      end
    end
  end
  
  define_method('test: 管理者ユーザ一覧を取得する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: 管理者ユーザを新規作成する') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 管理者ユーザを新規作成の確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :base_user => { :login => 'regist_test@drecom.co.jp', :email => 'regist_test@drecom.co.jp', :name => "テスト", 
                                   :password => 'testtest', :receive_system_mail_flag => true, :receive_mail_magazine_flag => true,
                                   :footmark_flag => true }
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: 管理者ユーザを新規作成の確認画面を表示しようとするが、ユーザは既に管理者なので新規作成画面を表示') do 
    login_as :quentin
    
    post :confirm, :base_user => { :login => 'mobilesns-dev@devml.drecom.co.jp', :email => 'mobilesns-dev@devml.drecom.co.jp', :name => "テスト", 
                                   :password => 'testtest', :receive_system_mail_flag => true, :receive_mail_magazine_flag => true,
                                   :footmark_flag => true }
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: create は管理者ユーザを新規作成実行する') do 
    login_as :quentin
    
    post :create, :base_user => { :login => 'regist_test@drecom.co.jp', :email => 'regist_test@drecom.co.jp', :name => "テスト", 
                                  :password => 'testtest', :receive_system_mail_flag => true, :receive_mail_magazine_flag => false,
                                  :footmark_flag => true, :joined_at => Time.now }
                              
    assert_response :redirect 
    assert_redirected_to :action => 'list'
    
    base_user = BaseUser.find_by_login('regist_test@drecom.co.jp')
    assert_not_nil(base_user)
    assert_equal(base_user.status, BaseUser::STATUS_ACTIVE) # ステータスは有効
    assert_equal(base_user.footmark_flag, true) 
    assert_equal(base_user.receive_system_mail_flag, true) 
    assert_equal(base_user.receive_mail_magazine_flag, false) 
    
    base_user.base_user_roles.each do |role|
      assert_equal role.role, 'manager' # 管理者である
    end
    
    assert_not_nil(base_user.base_profile) # プロフィールレコードも追加されている
  end
  
  define_method('test: 管理者ユーザを新規作成実行しようとするが、ユーザは既に管理者なので新規作成画面を表示') do 
    login_as :quentin
    
    post :create, :base_user => { :login => 'mobilesns-dev@devml.drecom.co.jp', :email => 'mobilesns-dev@devml.drecom.co.jp', :name => "テスト", 
                                  :password => 'testtest', :receive_system_mail_flag => true, :receive_mail_magazine_flag => true,
                                  :footmark_flag => true, :joined_at => Time.now }
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 管理者ユーザを新規作成実行をキャンセル') do 
    login_as :quentin
    
    post :create, :base_user => { :login => 'regist_test@drecom.co.jp', :email => 'regist_test@drecom.co.jp', :name => "テスト", 
                                  :password => 'testtest', :receive_system_mail_flag => true, :receive_mail_magazine_flag => true,
                                  :footmark_flag => true, :joined_at => Time.now },
                  :cancel => 'true'
    
    assert_response :success
    assert_template 'new'
    
    base_user = BaseUser.find_by_login('regist_test@drecom.co.jp')
    assert_nil(base_user) # キャンセルしたので管理者設定はされていない
  end
  
  define_method('test: 管理者ユーザ削除確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm'
  end
  
  define_method('test: 管理者ユーザ削除確認画面を表示しようとするが、管理者ユーザではないのでリストページへ遷移する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 3
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  end
  
  define_method('test: 管理者ユーザ削除実行をする') do 
    login_as :quentin
    
    # 事前チェック: base_user_id　= 1 は管理者
    base_user_role = BaseUserRole.find(:first, :conditions => [' base_user_id = 1 '])
    assert_not_nil base_user_role
    assert_equal base_user_role.role, 'manager'
    
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'list'
    
    base_user_role = BaseUserRole.find(:first, :conditions => [' base_user_id = 1 '])
    assert_nil base_user_role # 管理者ではなくなっている
  end
  
  define_method('test: 管理者ユーザではないユーザを管理者から外そうとしたので一覧ページに戻る') do 
    login_as :quentin
    
    post :delete, :id => 2
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  end
  
  define_method('test: 管理者ユーザ削除実行をキャンセルしたので一覧ページへ戻る') do 
    login_as :quentin
    
    post :delete, :id => 1, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  end
end
