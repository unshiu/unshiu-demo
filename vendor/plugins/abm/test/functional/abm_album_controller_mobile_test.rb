
module AbmAlbumControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_errors
        fixtures :abm_albums
        fixtures :abm_images
        fixtures :abm_image_comments
      end
    end
  end
  
  define_method('test: アルバムトップページはログインしていないとみれない') do
    get :index
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album"
  end
  
  define_method('test: アルバムトップページを表示する') do
    login_as :quentin
    
    get :index
    assert_response :success

    assert_instance_of PagingEnumerator, assigns["albums"]
    assert_equal 1, assigns["albums"].page
    assert_equal 5, assigns["albums"].page_size
    
    assigns["albums"].each do |album|
      assert_instance_of AbmAlbum, album
      assert_equal 1, album.base_user_id
    end
  end

  define_method('test: アルバム自体はログインしていなくても閲覧できる') do
    get :show, :id => 1
    assert_response :success
    
    assert_instance_of AbmAlbum, assigns["album"]
    assert_equal 1, assigns["album"].id
    assert_equal 1, assigns["album"].base_user_id
  end
  
  define_method('test: ログインしていると自分のアルバムが表示される') do
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
    
    assert_equal 1, assigns["album"].id
    assert_equal 1, assigns["album"].base_user_id
    
    assigns["images"].each do |image|
      assert_equal 1, image.abm_album_id
    end
  end
  
  define_method('test: アルバムの新規作成はログインしているユーザのみ可能') do
    get :new
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/new"
  end
  
  define_method('test: アルバムの新規作成画面を表示する') do
    login_as :quentin
    
    get :new
    assert_response :success
    
    assert_instance_of AbmAlbum, assigns["album"]
  end
  
  define_method('test: 新規作成確認画面はログインしていないと閲覧できない') do
    get :confirm
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/confirm"
  end
  
  define_method('test: 新規作成確認画面を表示する') do
    login_as :quentin
    
    album = AbmAlbum.new do |album| 
      album.title = "hoge"
      album.body  = "hogehoge"
      album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    end
    
    get :confirm, :album => album.attributes
    assert_response :success
    
    assert_instance_of AbmAlbum, assigns["album"]
    assert_equal "hoge", assigns["album"].title
    assert_equal "hogehoge", assigns["album"].body
    assert_equal UserRelationSystem::PUBLIC_LEVEL_ALL, assigns["album"].public_level
  end
  
  define_method('test: タイトルには必須なので欠けていると作成画面を表示する') do
    login_as :quentin
    
    album = AbmAlbum.new do |album| 
      album.title = " "
      album.body  = "hogehoge"
      album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    end
    
    get :confirm, :album => album.attributes
    assert_template "new_mobile"
    
    assert_instance_of AbmAlbum, assigns["album"]
    assert_not_nil assigns["album"].errors[:title]
  end
  
  define_method('test: アルバム新規作成はログインしていないとできない') do
    get :create
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/create"
  end
  
  define_method('test: アルバム新規作成の実行をする') do
    login_as :quentin
    
    album = AbmAlbum.new do |album| 
      album.title = "test_create_album"
      album.body  = "hogehoge"
      album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    end
    
    get :create, :album => album.attributes
    
    craete_album = AbmAlbum.find_by_title("test_create_album")
    assert_response :redirect
    assert_redirected_to :action => :done, :id => craete_album.id
  end

  define_method('test: 作成完了画面をはログインしていなければ閲覧できない。') do
    get :done, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/done/1"
  end
  
  define_method('test: 作成完了画面を表示する。') do
    login_as :quentin
    
    get :done, :id => 1
    assert_response :success
    
    assert_equal 1, assigns["album"].id
  end
  
  define_method('test: 作成完了画面は作成者でなければ閲覧できない') do
    login_as :quentin
    
    get :done, :id => 2
    assert_response :redirect
    error = BaseError.find_by_error_code_use_default("U-02001")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
    
  end
  
  define_method('test: アルバム編集はログインしていないとできない') do
    get :edit
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/edit"
  end
  
  define_method('test: アルバム編集ページを表示する') do
    login_as :quentin
    
    get :edit, :id => 1
    
    assert_response :success
    assert_equal 1, assigns["album"].id
  end
  
  define_method('test: 自分のアルバムしか編集ページを表示することはできない') do
    login_as :quentin
    
    get :edit, :id => 2

    assert_response :redirect
    error = BaseError.find_by_error_code_use_default("U-02001")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
  define_method('test: 更新確認を表示しようとするがログインしていないのでログイン画面へ遷移') do
    get :update_confirm
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/update_confirm"
  end
  
  define_method('test: 更新確認を表示する') do
    login_as :quentin
    
    album = AbmAlbum.new do |album| 
      album.title = "hoge"
      album.body  = "hogehoge"
      album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    end
    
    # validなalbumを渡す
    get :update_confirm, {:album => album.attributes, :id => 1}
    assert_instance_of AbmAlbum, assigns["album"]
    assert_equal "hoge", assigns["album"].title
    assert_equal "hogehoge", assigns["album"].body
    assert_equal UserRelationSystem::PUBLIC_LEVEL_ALL, assigns["album"].public_level
  end
  
  define_method('test: 更新確認を表示しようとするが、タイトルが空では保存できない') do
    login_as :quentin
    
    album = AbmAlbum.new do |album| 
      album.title = " "
      album.body  = "hogehoge"
      album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    end
    
    get :update_confirm, {:album => album.attributes, :id => 1}
    assert_instance_of AbmAlbum, assigns["album"]
    assert_not_nil assigns["album"].errors[:title]
  end
  
  define_method('test: 更新をしようとするがログインしていないのでログイン画面へ遷移') do
    get :update
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/update"
  end
  
  define_method('test: 更新処理を実行する') do
    login_as :quentin
    
    orig = AbmAlbum.find(1)

    orig.title = "hogehoge"
    post :update, {:album => orig.attributes, :id => orig.id}
    assert_response :redirect
    assert_redirected_to :action => :update_done, :id => orig.id

    a = AbmAlbum.find(1)
    assert_equal "hogehoge", a.title
    assert_equal orig.body, a.body
    assert_equal orig.public_level, a.public_level
    
    # TODO test case for "cancel?"
  end
  
  define_method('test: 更新処理を実行しようとするが自分のアルバムではないのでエラー画面へ遷移する') do
    login_as :quentin
    
    post :update, :id => 2
    assert_response :redirect
    
    error = BaseError.find_by_error_code_use_default("U-02001")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
  define_method('test: 更新完了画面を表示しようとするがログインしていないのでログイン画面へ遷移') do
    get :update_done
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/update_done"
  end
  
  define_method('test: 更新完了画面を表示しする') do
    login_as :quentin
    
    get :update_done, :id => 1
    assert_response :success
    assert_equal 1, assigns["album"].id
  end
  
  define_method('test: 削除確認画面はログインしていないと閲覧できない') do
    get :confirm_delete
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/confirm_delete"
  end
  
  define_method('test: 削除確認画面を表示する') do
    login_as :quentin
    
    get :confirm_delete, :id => 1
    assert_response :success
    
    assert_equal 1, assigns["album"].id
  end
  
  define_method('test: アルバム削除を実行しようとするがログインしていないのでエラー画面へ遷移する') do
    get :delete, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/delete/1"
  end
  
  define_method('test: アルバム削除を実行する') do
    login_as :quentin
    
    get :delete, :id => 1
    assert_response :redirect
    assert_redirected_to :action => :delete_done, :id => 1
    
    assert_equal 1, assigns["album"].id
    
    abm_album = AbmAlbum.find_by_id(1)
    assert_nil(abm_album) # 削除済み
  end
  
  define_method('test: 自分のアルバムしか削除できない。') do
    login_as :quentin
    
    get :delete, :id => 2
    assert_response :redirect
    error = BaseError.find_by_error_code_use_default("U-02001")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
    
    abm_album = AbmAlbum.find_by_id(2)
    assert_not_nil(abm_album) # 削除されてない
  end
  
  define_method('test: 削除完了ページはログインしていなければ閲覧できない') do
    get :delete_done, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/delete_done/1"
  end
  
  define_method('test: 削除完了ページを表示する') do
    login_as :quentin
    
    get :delete_done, :id => 1
    assert_response :success
    
    assert_instance_of AbmAlbum, assigns["album"]
    assert_equal 1, assigns["album"].id
  end

  define_method('test: list はログインしていない場合全体への公開アルバムを表示する') do
    get :list, :id => 1
    assert_response :success
  end

  define_method('test: list はログインしている場合、指定されたユーザのアルバム一覧ページを表示する') do
    login_as :quentin
    
    get :list, :id => BaseUser.find(1).id
    assert_response :success
    
    assert_instance_of BaseUser, assigns["user"]
    assert_equal 1, assigns["user"].id
    
    assert_not_nil assigns["albums"]
    assert assigns["albums"].size <= AppResources['abm']['album_list_size']
    assigns["albums"].each do |album|
      assert_equal 1, album.base_user_id
    end
  end
  
  def test_public_list
    
    get :public_list
    albums = assigns["albums"]
    assert_not_nil albums
    assert albums.size <= AppResources['abm']['album_list_size_mobile']
    albums.each do |a|
      assert_equal UserRelationSystem::PUBLIC_LEVEL_ALL, a.public_level
    end
    
  end
  # TODO owner_only filter test
  
  define_method('test: friend_list は友達のアルバム一覧を表示する') do
    login_as :quentin
    
    get :friend_list
    albums = assigns["albums"]
    assert_not_nil albums
    assert albums.size <= AppResources['abm']['album_list_size_mobile']
    albums.each do |a|
      assert_equal UserRelationSystem::PUBLIC_LEVEL_ALL, a.public_level
    end
  end
  
  define_method('test: アルバムの投稿アドレスを表示しようとするがログインしていないのでエラー画面へ遷移する') do
    get :show_address
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/show_address"
  end
  
  define_method('test: アルバムの投稿アドレスを表示する') do
    login_as :quentin
    
    get :show_address, :id => 1
    assert_response :success
    
    assert_not_nil assigns["address"]
    assert_instance_of String, assigns["address"]
  end
  
  define_method('test: 自分のアルバムではないアルバムの投稿用アドレスを見ようとするとエラー画面へ遷移する') do
    login_as :quentin

    get :show_address, :id => 3
    assert_response :redirect
    
    error = BaseError.find_by_error_code_use_default("U-02001")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
end
  