
module BaseUserControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_friends
      end
    end
  end
  
  def test_should_login_and_redirect
    post :login, :login => 'quentin', :password => 'test'
    assert session[:base_user]
    assert_response :redirect
  end

  define_method('test: パスワードがまちがっていたらログインできない') do 
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:base_user]
    
    assert_response :success
    assert_template 'login_mobile'
  end
  
  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:base_user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :login, :login => 'quentin', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end

  define_method('test: 携帯端末IDによるかんたんログインをする') do 
    # キャリアごとにリクエストパラメータにテスト用の test_util.rb でのせている
    post :simple_login, :login => 'quentin'
    
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'portal'
    
    assert_not_nil session[:base_user]
    assert_equal(session[:base_user], 1) # login後にセッションが追加
  end

  define_method('test: 携帯IDが取得できない場合はログイン画面へ戻る') do 
    @request.env["HTTP_USER_AGENT"] = "DoCoMo/2.0 SH903i(c100;TB;W24H16)" if @request.user_agent =~ /DoCoMo/
    @request.env["HTTP_X_UP_SUBNO"] = nil
    @request.env["HTTP_X_JPHONE_UID"] = nil
    
    post :simple_login, :login => 'quentin'
    
    assert_response :redirect
    assert_redirected_to :action => 'login'
    
    assert_nil session[:base_user]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :logout
    assert_equal @response.cookies["auth_token"], nil
  end

  def test_should_login_with_cookie
    base_users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert @controller.send(:logged_in?)
  end
    
  def test_should_fail_expired_cookie_login
    base_users(:quentin).remember_me
    base_users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    base_users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    assert !@controller.send(:logged_in?)
  end
  
  define_method('test: ユーザ検索ページを表示する') do 
    login_as :quentin
    
    post :search
    assert_response :success
    assert_template 'search_mobile'
  end
  
  define_method('test: list はユーザ検索結果ページを表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: list は検索キーワードがなければ全ユーザを表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
    
    assert_not_equal(assigns['users'].size, 0)
    assigns['users'].each do |user|
      assert_equal(user.status, BaseUser::STATUS_ACTIVE)
      assert_equal(user.base_profile.name_public_level, UserRelationSystem::PUBLIC_LEVEL_ALL)
    end
  end
  
  define_method('test: list は名前を半角空白で検索されたら全ユーザを表示する') do 
    login_as :quentin
    
    post :list, :name => ' '
    assert_response :success
    assert_template 'list_mobile'
    
    assert_not_equal(assigns['users'].size, 0)
    assigns['users'].each do |user|
      assert_equal(user.status, BaseUser::STATUS_ACTIVE)
      assert_equal(user.base_profile.name_public_level, UserRelationSystem::PUBLIC_LEVEL_ALL)
    end
  end
  
private  
  
  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(base_user)
    auth_token base_users(base_user).remember_token
  end  
end