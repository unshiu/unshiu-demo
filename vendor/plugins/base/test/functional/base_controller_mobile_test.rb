
module BaseControllerMobileTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_friends
        fixtures :base_notices
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :abm_albums
        fixtures :abm_image_comments
        fixtures :tpc_topic_cmm_communities
        fixtures :tpc_comments
        fixtures :tpc_topics
        fixtures :jpmobile_carriers
        fixtures :jpmobile_devices
      end
    end
  end
  
  define_method('test: 許可されていない端末でアクセスしたため専用エラーページに遷移する') do 
    @request.env["HTTP_USER_AGENT"] = "DoCoMo/2.0 xxxxxxxx" # 機種情報を取得できない
    
    get :portal
    assert_response :success
    assert_match /unavaliable_mobile/, @response.body
  end
  
  define_method('test: リクエスト元のIPアドレスが携帯端末以外なので制限チェックをしない') do 
    @request.remote_addr = "127.0.0.1"
    @request.user_agent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6) Gecko/20050223 Firefox/1.0.1'
    @request.env["HTTP_USER_AGENT"] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6) Gecko/20050223 Firefox/1.0.1" # 機種情報を取得できない
    
    get :portal
    assert_response :redirect
    assert_redirected_to :controller => 'base_user', :action => 'login', :return_to => '/base/portal'
  end
  
  define_method('test: トップページは非ログインでも閲覧できる') do    
    get :index
    assert_response :success
  end
  
  define_method('test: ログインしてトップページを表示する') do  
    login_as :quentin
    
    get :index
    assert_response :success
  end
  
  define_method('test: ポータルを表示する') do 
    login_as :quentin
    
    get :portal
    assert_response :success
    assert_template 'portal_mobile'
  end
  
  define_method('test: ポータルを表示しようとするがログインしていないのでログイン画面へ遷移する') do 
    get :portal
    assert_response :redirect
    assert_redirected_to :controller => 'base_user', :action => 'login', :return_to => '/base/portal'
  end
  
  define_method('test: ポータルを表示する際、ログイン履歴は更新する') do 
    cache = BaseLatestLogin.find_by_base_user_id(1)
    cache.destroy if cache # 念のため削除しておく
    
    login_as :quentin
    
    get :portal
    assert_response :success
    assert_template 'portal_mobile'
    
    base_latest_login = BaseLatestLogin.find_by_base_user_id(1)
    assert_not_nil(base_latest_login.latest_login) # 最終日付がある
  end
  
  define_method('test: 検索ページはログインをしていなくても閲覧できる') do 
    get :search
    assert_response :success
  end
  
  define_method('test: ログインをして検索ページを表示する') do
    login_as :quentin
    get :search
    assert_response :success
  end
  
  define_method('test: 問い合わせページはログインをしていなくても閲覧できる') do 
    get :inquire_input
    assert_response :success
  end
  
  define_method('test: ログインをして問い合わせページを表示する閲覧できる') do 
    login_as :quentin
    get :inquire_input
    assert_response :success
  end
  
  define_method('test: ログインをして問い合わせ確認ページを表示する') do
    login_as :quentin
    get :inquire_confirm, :inquire => {:body => 'test', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :success
    assert_template 'inquire_confirm_mobile'
  end

  define_method('test: ログインをしていなくても問い合わせ確認ページを表示することはできる') do
    post :inquire_confirm, :inquire => {:body => 'test', :mail_address => 'test@test.test', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :success
    assert_template 'inquire_confirm_mobile'
  end

  define_method('test: 内容に不備があった場合は確認画面は表示できない') do
    login_as :quentin
    
    get :inquire_input, :inquire => {:body => '', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :success
    assert_template 'inquire_input_mobile'
  end
  
  define_method('test: 非ログイン状態で問い合わせを実行する') do
    post :inquire, :inquire => {:body => 'test', :mail_address => 'test@unshiu.drecom.co.jp', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :redirect
    assert_redirected_to :action => 'inquire_done'
  end
  
  define_method('test: 問い合わせを実行する') do
    login_as :quentin
    
    post :inquire, :inquire => {:body => 'test', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :redirect
    assert_redirected_to :action => 'inquire_done'
  end
  
  define_method('test: 問い合わせをキャンセルする') do
    post :inquire, :cancel => 'cancel', :inquire => {:body => 'test', :mail_address => 'test@test.test', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :success
    assert_template 'inquire_input_mobile'
  end
  
  define_method('test: 機種変更時の注意点を表示する') do
    login_as :quentin
    
    post :device_change
    assert_response :success
    assert_template 'device_change_mobile'
  end

  define_method('test: 機種変更時の注意点はログインしていなくても閲覧できる') do
    post :device_change
    assert_response :success
    assert_template 'device_change_mobile'
  end
  
  define_method('test: 対応機種について表示する') do
    login_as :quentin
    
    post :device
    assert_response :success
    assert_template 'device_mobile'
  end

  define_method('test: 対応機種についてはログインしていなくても閲覧できる') do
    post :device
    assert_response :success
    assert_template 'device_mobile'
  end
  
  def test_error
    get :error, :error_message => 'えらー'
    assert_response :success
    
    login_as :quentin
    get :error, :error_message => 'えらー'
    assert_response :success
  end
  
end