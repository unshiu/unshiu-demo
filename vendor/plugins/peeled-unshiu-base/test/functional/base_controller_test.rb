
module BaseControllerTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
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
        fixtures :base_menus
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :dia_entries_abm_images
      end
    end
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
    assert_template 'portal'
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
    assert_template 'portal'
    
    base_latest_login = BaseLatestLogin.find_by_base_user_id(1)
    assert_not_nil(base_latest_login.latest_login) # 最終日付がある
  end
  
  define_method('test: ユーザのメニュー一覧を更新する') do    
    login_as :quentin
    
    # base_menu_master_id = 1 の　並び順を　4 番目に変更
    post :menus_update, :base_menu_master_id => 1, :num => 4
    assert_response :success
    
    base_menus = BaseMenu.find(:all, :conditions => ['base_user_id = 1'], :order => ["base_menu_master_id"])
    
    assert_equal(base_menus[0].num, 4)
    assert_equal(base_menus[1].num, 1)
    assert_equal(base_menus[2].num, 2)
    assert_equal(base_menus[3].num, 3)
    assert_equal(base_menus[4].num, 5)
    assert_equal(base_menus[5].num, 6)  
  end
  
  define_method('test: ユーザのメニュー設定をされていないユーザが設定を更新しようとするとデフォルトを元に作成し、更新する') do    
    login_as :aaron
    
    # base_menu_master_id = 2 の　並び順を　4 番目に変更
    post :menus_update, :base_menu_master_id => 2, :num => 4
    assert_response :success
    
    base_menus = BaseMenu.find(:all, :conditions => ['base_user_id = 2'], :order => ["base_menu_master_id"])
    
    assert_equal(base_menus[0].num, 1) # デフォルトの base_menu_masterの関係があるので
    assert_equal(base_menus[1].num, 4)
    assert_equal(base_menus[2].num, 6)
    assert_equal(base_menus[3].num, 2)
    assert_equal(base_menus[4].num, 5)
    assert_equal(base_menus[5].num, 3)  
  end
  
  define_method('test: search はユーザ検索結果ページを表示する') do
    login_as :quentin
    
    get :search, :base_search => { :keyword => 'quentin', :scope => 'base_user' }
    assert_response :success
    assert_template 'search'
    
    results = assigns["results"]
    assert_equal(results.size, 1)
    assert_instance_of(BaseUser, results.to_a[0])
  end
  
  define_method('test: search は検索キーワードがなければユーザ検索全体の結果ページを表示する') do
    login_as :quentin
    
    get :search, :base_search => { :keyword => '', :scope => 'base_user' }
    assert_response :success
    assert_template 'search'
    
    assert_equal(assigns["results"].size, BaseUser.active.size)
  end
  
  define_method('test: search はログインしていなくても検索して結果を表示する') do 
    get :search, :base_search => { :keyword => "", :scope => 'base_user' }
    
    assert_response :success
    assert_template 'search'
  end
  
  define_method('test: search は日記検索結果ページを表示する') do
    DiaEntry.clear_index!
    DiaEntry.reindex!

    login_as :quentin
    
    get :search, :base_search => { :keyword => 'テストタイトル', :scope => 'dia' }
    assert_response :success
    assert_template 'search'
    
    results = assigns["results"]
    assert_instance_of(DiaEntry, results.to_a[0])
  end
  
  define_method('test: search は検索キーワードがなければ公開日記一覧結果ページを表示する') do
    DiaEntry.clear_index!
    DiaEntry.reindex!
    
    login_as :quentin

    get :search, :base_search => { :keyword => '', :scope => 'dia' }
    assert_response :success
    assert_template 'search'
    
    results = assigns["results"]
    results.each do |result|
      assert_instance_of(DiaEntry, result)
      assert_equal(result.public_level, 1)
    end
  end
  
  define_method('test: search はアルバム検索結果ページを表示する') do
    login_as :quentin
    
    get :search, :base_search => { :keyword => '写真', :scope => 'abm' }
    assert_response :success
    assert_template 'search'
    
    results = assigns["results"]
    assert_instance_of(AbmImage, results.to_a[0])
  end
  
  define_method('test: search は検索キーワードがなければ公開アルバム一覧結果ページを表示する') do
    login_as :quentin
    
    get :search, :base_search => { :keyword => '', :scope => 'abm' }
    assert_response :success
    assert_template 'search'
    
    results = assigns["results"]
    results.each do |result|
      assert_instance_of(AbmImage, result)
      assert_equal(result.abm_album.public_level, 1)
    end
  end
  
  define_method('test: search はコミュニティ検索結果ページを表示する') do
    CmmCommunity.clear_index!
    CmmCommunity.reindex!
    
    login_as :quentin
    
    get :search, :base_search => { :keyword => 'one', :scope => 'cmm' }
    assert_response :success
    assert_template 'search'
    
    results = assigns["results"]
    assert_instance_of(CmmCommunity, results.to_a[0])
  end
  
  define_method('test: search は検索キーワードがなければ公開コミュニティ一覧結果ページを表示する') do
    CmmCommunity.clear_index!
    CmmCommunity.reindex!
    
    login_as :quentin
    
    get :search, :base_search => { :keyword => '', :scope => 'cmm' }
    assert_response :success
    assert_template 'search'
    
    results = assigns["results"]
    assert_not_equal(results.size, 0)
    results.each do |result|
      assert_instance_of(CmmCommunity, result)
    end
  end
  
  define_method('test: inquire_input はログインをしていなくても問い合わせページを表示する') do 
    get :inquire_input
    
    assert_response :success
    assert_template 'inquire_input'
  end
  
  define_method('test: inquire_input は問い合わせページを表示す') do 
    login_as :quentin
    get :inquire_input
    
    assert_response :success
    assert_template 'inquire_input'
  end
  
  define_method('test: inquire はログインしていなくても問い合わせを実行できる') do
    post :inquire, :inquire => {:body => 'test', :mail_address => 'test@unshiu.drecom.co.jp', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'index'
  end
  
  define_method('test: inquire は問い合わせを実行する') do
    login_as :quentin
    
    post :inquire, :inquire => {:body => 'test', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :redirect
    assert_redirected_to :controller => 'base', :action => 'index'
  end
  
  define_method('test: inquire はキャンセルボタンを押されたたら問い合わせをキャンセルする') do
    post :inquire, :cancel => 'cancel', :inquire => {:body => 'test', :mail_address => 'test@test.test', :referer => 'http://unshiu.drecom.jp/'}
    assert_response :success
    assert_template 'inquire_input'
  end

end