
module BaseSignupControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_friends
        fixtures :base_mail_templates
        fixtures :base_mail_template_kinds
      end
    end
  end
  
  define_method('test: presignup はユーザ登録のためのメールアドレス登録フォーム画面を表示') do    
    get :presignup
    assert_response :success
    assert_template 'presignup'
    
    assert_not_nil(assigns["base_mail_address_form"])
  end
  
  define_method('test: mail_regist はメールアドレスをシステムに登録し仮登録メール送信をまつ') do
    post :mail_regist, :base_mail_address_form => { :mail_address => 'test_mail_regist@unshiu.drecom.jp'}
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'index'
    
    assert_not_nil(flash[:notice])
    
    base_user = BaseUser.find_by_email('test_mail_regist@unshiu.drecom.jp')
    assert_not_nil(base_user)
    assert(!base_user.active?) # まだ有効なアカウントではない
  end
  
  define_method('test: mail_regist は不正なメールアドレスを入力された場合入力画面に戻りエラーを表示する') do
    post :mail_regist, :base_mail_address_form => { :mail_address => 'あいうえお'}
    
    assert_response :success
    assert_template 'presignup'
  end
  
  define_method('test: mail_regist は既に登録済みのメールアドレスの場合、入力画面を表示しその旨を通知する') do
    post :mail_regist, :base_mail_address_form => { :mail_address => BaseUser.find(1).email }
    
    assert_response :success
    assert_template 'presignup'
  end
  
  define_method('test: 利用規約同意＋ユーザ登録画面を表示する') do 
    post :ask_agreement, :id => 'activation'
    assert_response :success
    assert_template 'ask_agreement'
    
    assert_not_nil(assigns['activation_code'])
    assert_nil(assigns['invite'])
  end
  
  define_method('test: 利用規約同意＋ユーザ登録画面を表示しようとするがアクティベーションコードが無効なのでエラー画面へ遷移') do 
    post :ask_agreement, :id => '無効なアクティベーションコード'
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: signup はユーザ登録処理実行をする') do 
    before_base_user = BaseUser.find_by_id(11)
    assert_not_nil(before_base_user)
    assert_equal(before_base_user.status, 1) # 事前確認：ステータスは仮登録
    
    post :signup, :id => 'activation', 
                  :user => { :email => 'user@drecom.co.jp', :login => 'test create user', :password => 'test', :receive_mail_magazine_flag => 'false' }
    
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'portal' 
    
    base_user = BaseUser.find_by_id(11)
    assert_not_nil(base_user)
    assert_equal(base_user.receive_mail_magazine_flag, false)
    assert_equal(base_user.status, 2) # ステータスは登録済み
    
    base_profile = BaseProfile.find(:first, :conditions => ['base_user_id = 11'])
    assert_not_nil(base_profile) # プロフィール情報が作成されている
    assert_nil(base_profile.name) # 名前は未設定
  end
  
  define_method('test: signup はユーザ登録処理情報に問題があったら利用規約同意画面を再度表示する') do 
    before_base_user = BaseUser.find_by_id(11)
    assert_not_nil(before_base_user)
    assert_equal(before_base_user.status, 1) # 事前確認：ステータスは仮登録
    
    post :signup, :id => 'activation', 
                  :user => { :email => 'user@drecom.co.jp', :login => '', :password => 'test', :receive_mail_magazine_flag => 'false' }
                  # login id が空
                  
    assert_response :success
    assert_template "ask_agreement"
    
    base_user = BaseUser.find_by_id(11)
    assert_not_nil(base_user)
    assert_equal(base_user.status, 1) # ステータスは仮登録のまま
  end
  
  define_method('test: password_remind_ask はパスワードリマインダー画面を表示する') do
    login_as :quentin
    
    post :password_remind_ask
    assert_response :success
    assert_template 'password_remind_ask'
  end
  
  define_method('test: password_remind はパスワード再設定用メール送信処理実行') do
    login_as :quentin
    
    post :password_remind, :mail_address => 'mobilesns-dev@devml.drecom.co.jp'
    assert_response :redirect
    assert_redirected_to :controller => :base, :action => 'index'
  end
  
  define_method('test: password_remind はパスワード再設定用メール送信処理をしようとするがアドレスが無効な書式のために入力画面へ戻る') do
    login_as :quentin
    
    post :password_remind, :mail_address => 'aaaa'
    assert_response :success
    assert_template 'password_remind_ask'
  end
  
  define_method('test: password_set_ask はパスワード再設定入力画面を表示') do
    login_as :quentin
    
    post :password_set_ask
    assert_response :success
    assert_template 'password_set_ask'
  end
  
  define_method('test: password_set はログイン状態だとパスワード再設定入力確認画面を表示') do
    login_as :quentin
    
    post :password_set, :password => 'repassword'
    assert_response :redirect
    assert_redirected_to :controller => 'base_user_config', :action => 'index'
    
    base_user = BaseUser.find_by_id(1)
    # 暗号化されているのでデフォルト状態から変わっていることだけを確認
    assert_not_equal base_user.crypted_password, '00742970dc9e6319f8019fd54864d3ea740f04b1'    
  end
  
  define_method('test: password_set はアクティベートコードでパスワード再設定入力確認画面を表示（メールからの遷移）') do
    post :password_set, :id => 'activation', :password => 'test'
    
    assert_response :redirect
    assert_redirected_to :controller => 'base_user_config', :action => 'index'
  end
  
  define_method('test: password_set はパスワードが不正な値だと登録画面を表示する') do
     login_as :quentin
    
    post :password_set, :password => 'te st'
    assert_response :success
    assert_template 'password_set_ask'
  end
  
  define_method('test: quit_confirm は退会確認画面を表示する') do
    login_as :ten
    
    post :quit_confirm
    assert_response :success
    assert_template 'quit_confirm'
  end
  
  define_method('test: quit_confirm は管理者の場合退会できないのでエラー画面へ遷移する') do
    login_as :quentin
    
    post :quit_confirm
    assert_response :redirect
    assert_redirect_with_error_code 'U-01022'
  end
  
  define_method('test: quit は退会処理実行をする') do
    login_as :three
    
    post :quit
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'index'
    assert_not_nil(flash[:notice])
    
    base_user = BaseUser.find_by_id(3)
    assert_nil(base_user) # 削除はされている
    
    with_delete_base_user = BaseUser.find(:first, :conditions => [' id = 3 '], :with_deleted => true)
    assert_not_nil(with_delete_base_user.quitted_at)
    assert_equal(with_delete_base_user.status, BaseUser::STATUS_WITHDRAWAL)
  end
  
  define_method('test: quit は管理者の場合、退会処理できないのでエラー画面へ遷移する') do
    login_as :quentin
    
    post :quit
    assert_response :redirect
    assert_redirect_with_error_code 'U-01022'
    
    base_user = BaseUser.find_by_id(1)
    assert_not_nil(base_user) # 削除はされていない
    
    with_delete_base_user = BaseUser.find(:first, :conditions => [' id = 1 '], :with_deleted => true)
    assert_nil(with_delete_base_user.quitted_at)
    assert_not_equal(with_delete_base_user.status, BaseUser::STATUS_WITHDRAWAL)
  end
end