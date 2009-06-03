
module BaseSignupControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
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
  
  define_method('test: 仮登録用のアドレス確認画面をを表示する') do 
    post :presignup
    assert_response :success
    assert_template 'presignup_mobile'
  end
  
  define_method('test: 利用規約同意画面を表示する') do 
    post :ask_agreement, :id => 'activation'
    assert_response :success
    assert_template 'ask_agreement_mobile'
  end
  
  define_method('test: 利用規約同意画面を表示しようとするがアクティベーションコードが無効なのでエラー画面へ遷移') do 
    post :ask_agreement, :id => '無効なアクティベーションコード'
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: ユーザ名を登録する画面を表示') do 
    post :ask_names, :id => 'activation', :user => { :id => 11 }
    assert_response :success
    assert_template 'ask_names_mobile'
  end
  
  define_method('test: ユーザ名を登録する画面を表示') do 
    post :ask_names, :id => 'activation', :user => { :id => 11 }
    assert_response :success
    assert_template 'ask_names_mobile'
  end
  
  define_method('test: ユーザ名を登録する画面を表示をキャンセル') do 
    post :ask_names, :id => 'activation', :user => { :id => 11 }, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'index'
  end
  
  define_method('test: confirm はユーザ登録処理の確認画面を表示する') do 
    post :confirm, :id => 'activation', 
                   :user => { :email => 'user@drecom.co.jp', :login => 'user@drecom.co.jp', :password => 'test', :receive_mail_magazine_flag => 'true' }
    
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: signup はユーザ登録処理実行をする') do 
    
    before_base_user = BaseUser.find_by_id(11)
    assert_not_nil(before_base_user)
    assert_equal(before_base_user.status, 1) # 事前確認：ステータスは仮登録
    
    post :signup, :id => 'activation', 
                  :user => { :email => 'user@drecom.co.jp', :login => 'user@drecom.co.jp', :password => 'test', :receive_mail_magazine_flag => 'false' }
    
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
  
  define_method('test: 誘われた友達がいる状態でユーザ登録処理実行をする') do
  
    post :signup, :id => 'activation', 
                  :invite => 1, # base_user_id = 1 の人が招待した
                  :user => { :email => 'user@drecom.co.jp', :login => 'user@drecom.co.jp', :password => 'test', :receive_mail_magazine_flag => 'false' }
    
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'portal' 
    
    base_user = BaseUser.find_by_id(11)
    assert_not_nil(base_user)
    assert_equal(base_user.receive_mail_magazine_flag, false)
    assert_equal(base_user.status, 2) # ステータスは登録済み
    
    base_profile = BaseProfile.find(:first, :conditions => ['base_user_id = 11'])
    assert_not_nil(base_profile) # プロフィール情報が作成されている
    assert_nil(base_profile.name) # 名前は未設定
    
    # お互い友達同士
    from_base_friend = BaseFriend.find(:first, :conditions => [' base_user_id = 1 and friend_id = 11 '])
    assert_not_nil(from_base_friend)
    to_base_friend = BaseFriend.find(:first, :conditions => [' base_user_id = 11 and friend_id = 1 '])
    assert_not_nil(to_base_friend) 
  end
  
  define_method('test: ユーザ登録処理実行をキャンセする') do
    
    post :signup, :id => 'activation', 
                  :invite => 1, # base_user_id = 1 の人が招待した
                  :user => { :email => 'user@drecom.co.jp', :login => 'user@drecom.co.jp', :password => 'test', :receive_mail_magazine_flag => 'false' },
                  :cancel => 'true'
    
    assert_response :success
    assert_template 'ask_names_mobile'
  end
  
  define_method('test: 退会確認画面を表示する') do
    login_as :ten
    
    post :quit_confirm
    assert_response :success
    assert_template 'quit_confirm_mobile'
  end
  
  define_method('test: 退会確認画面を表示しようとするが管理者なのでエラー画面へ遷移する') do
    login_as :quentin
    
    post :quit_confirm
    assert_response :redirect
    assert_redirect_with_error_code 'U-01022'
  end
  
  define_method('test: 退会処理実行をする') do
    login_as :three
    
    post :quit
    assert_response :redirect
    assert_redirected_to :action => 'quit_done'
    
    base_user = BaseUser.find_by_id(3)
    assert_nil(base_user) # 削除はされている
    
    with_delete_base_user = BaseUser.find(:first, :conditions => [' id = 3 '], :with_deleted => true)
    assert_not_nil(with_delete_base_user.quitted_at)
    assert_equal(with_delete_base_user.status, BaseUser::STATUS_WITHDRAWAL)
  end
  
  define_method('test: 退会処理実行をしようとするが管理者なのでエラー画面へ遷移する') do
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
  
  define_method('test: password_remind_ask はパスワードリマインダー画面を表示する') do
    login_as :quentin
    
    post :password_remind_ask
    assert_response :success
    assert_template 'password_remind_ask_mobile'
  end
  
  define_method('test: password_remind_confirm はパスワードリマインダー設定確認画面を表示する') do
    login_as :quentin
    
    post :password_remind_confirm, :mail_address => 'mobilesns-dev@devml.drecom.co.jp'
    assert_response :success
    assert_template 'password_remind_confirm_mobile'
  end
  
  define_method('test: password_remind_confirm  はパスワードリマインダー設定確認画面を表示しようとするが、フォーマットに問題があるメールアドレスだったので入力画面を表示') do
    login_as :quentin
    
    post :password_remind_confirm, :mail_address => 'aaaaa'
    assert_response :success
    assert_template 'password_remind_ask_mobile'
  end
  
  define_method('test: password_remind パスワードリマインドメール送信処理実行する') do
    login_as :quentin
    
    post :password_remind, :mail_address => 'mobilesns-dev@devml.drecom.co.jp'
    assert_response :redirect
    assert_redirected_to :action => 'password_remind_done'
  end
  
  define_method('test: password_remind はキャンセルボタンをおされたらパスワード再設定用メール送信処理実行をキャンセルする') do
    login_as :quentin
    
    post :password_remind, :mail_address => 'mobilesns-dev@devml.drecom.co.jp', :cancel => 'true'
    assert_response :success
    assert_template 'password_remind_ask_mobile'
  end
  
  define_method('test: パスワード再設定入力画面を表示') do
    login_as :quentin
    
    post :password_set_ask
    assert_response :success
    assert_template 'password_set_ask_mobile'
  end
  
  define_method('test: ログイン状態でパスワード再設定入力確認画面を表示') do
    login_as :quentin
    
    # TODO この辺action命名規則がぐちゃぐちゃ
    post :password_set, :password => 'repassword'
    assert_response :redirect
    assert_redirected_to :action => 'password_set_done'
    
    base_user = BaseUser.find_by_id(1)
    # 暗号化されているのでデフォルト状態から変わっていることだけを確認
    assert_not_equal base_user.crypted_password, '00742970dc9e6319f8019fd54864d3ea740f04b1'    
  end
  
  define_method('test: アクティベートコードでパスワード再設定入力確認画面を表示（メールからの遷移）') do
    post :password_set, :id => 'activation', :password => 'test'
    
    assert_response :redirect
    assert_redirected_to :action => 'password_set_done'
  end
  
  define_method('test: ログイン状態でパスワード再設定入力確認画面を表示しようとするが、パスワードにスペースがはいっているので登録画面を表示') do
     login_as :quentin
    
    post :password_set, :password => 'te st'
    assert_response :success
    assert_template 'password_set_ask_mobile'
  end
  
end