
module AbmAlbumControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_errors
        fixtures :abm_albums
        fixtures :abm_images
        fixtures :abm_image_comments
        
        use_transactional_fixtures = false
        
      end
    end
  end
  
  define_method('test: アルバム個別ページを表示する') do
    backup = AppResources['abm']['album_list_size']
    backup_user = AppResources[:abm][:user_size_max_image_size]
    backup_system = AppResources[:abm][:system_size_max_image_size]
    
    AppResources['abm']['album_list_size'] = 20
    AppResources[:abm][:user_size_max_image_size] = "100M"
    AppResources[:abm][:system_size_max_image_size] = "100M"
    
    update_path = RAILS_ROOT + "/test/tmp/file_column/abm_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    21.times do |n|
      image_data = uploaded_file(file_path("file_column/abm_image/image/7/logo.gif"), "not/known", "local_filename.jpg")
      abm_image = AbmImage.new({:abm_album_id => 1, :swfupload_file => image_data})
      abm_image.save!
    end
    
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    
    count = AbmImage.count(:conditions => ['abm_album_id = 1'])
    
    assert_not_nil(assigns["images"])
    assert_equal(assigns["images"].size, count)
    assert_equal(assigns["images"].last_page, (count / 9)+1) # 表示限度を9としたとき分のページ数
    
    AppResources['abm']['album_list_size'] = backup
    AppResources[:abm][:user_size_max_image_size] = backup_user
    AppResources[:abm][:system_size_max_image_size] = backup_system
  end
  
  define_method('test: アルバム新規作成ページを表示する') do
    login_as :quentin
    
    get :new
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: アルバムを新規作成する') do
    login_as :quentin
    
    assert_difference 'AbmAlbum.count', 1 do
      post :create, :album => { :title => 'abm_album_ctonrller_test create titl', 
                                :body => 'dia_etnry_controller_test create body',
                                :public_level => 1 }
    end
    
    assert_response :redirect
    assert_redirected_to :action => :index
  end
  
  define_method('test: create はアルバムを新規作成する際に内容に問題があれば編集画面へ戻る') do
    login_as :quentin
    
    assert_difference 'AbmAlbum.count', 0 do # 作成されてない
      post :create, :album => { :title => '', # 空欄 
                                :body => 'dia_etnry_controller_test create body',
                                :public_level => 1 }
    end
    
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: アルバム編集ページを表示する') do
    login_as :quentin
    
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    
    assert_equal 1, assigns["album"].id
  end
  
  define_method('test: 自分のアルバムしか編集ページを表示することはできない') do
    login_as :quentin
    
    get :edit, :id => 2

    assert_response :redirect
    assert_redirect_with_error_code("U-02001")
  end
  
  define_method('test: 更新処理を実行する') do
    login_as :quentin
    
    abm_album = AbmAlbum.find(1)

    abm_album.title = "hogehoge"
    post :update, {:album => abm_album.attributes, :id => abm_album.id}
    
    assert_response :redirect
    assert_redirected_to :action => :index

    after_abm_album = AbmAlbum.find(1)
    assert_equal "hogehoge", after_abm_album.title
    assert_equal abm_album.body, after_abm_album.body
    assert_equal abm_album.public_level, after_abm_album.public_level
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
    assert_template "confirm_delete"
    
    assert_equal 1, assigns["album"].id
  end
  
  define_method('test: delete はログインしていない削除処理をせずログイン画面を表示する') do
    get :delete, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_album/delete/1"
  end
  
  define_method('test: delete は削除処理を実行する') do
    login_as :quentin
    
    get :delete, :id => 1
    assert_response :redirect
    assert_redirected_to :action => :index
    
    assert_equal 1, assigns["album"].id
    
    abm_album = AbmAlbum.find_by_id(1)
    assert_nil(abm_album) # 削除済み
  end
  
  define_method('test: delete はキャンセルボタンを押されたら削除処理を実行せずアルバム個別ページを表示する') do
    login_as :quentin
    
    get :delete, :id => 1, :cancel => "true"
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    abm_album = AbmAlbum.find_by_id(1)
    assert_not_nil(abm_album) # 削除されてない
  end
  
  define_method('test: delete はキャンセルボタンを押され戻り先が指定されていtら指定先へ戻る') do
    login_as :quentin
    
    get :delete, :id => 1, :cancel => "true", :cancel_to => "/abm_album/list"
    assert_response :redirect
    assert_redirected_to :controller => :abm_album, :action => :list
    
    abm_album = AbmAlbum.find_by_id(1)
    assert_not_nil(abm_album) # 削除されてない
  end
  
  define_method('test: list はログインしていない場合全体への公開アルバムを表示する') do
    get :list, :id => 1
    assert_response :success
  end

  define_method('test: list はログインしている場合、指定されたユーザのアルバム一覧ページを表示する') do
    login_as :quentin
    
    get :list, :id => 1
    assert_response :success
    
    assert_instance_of BaseUser, assigns["user"]
    assert_equal 1, assigns["user"].id
    
    assert_not_nil assigns["albums"]
    assert assigns["albums"].size <= AppResources['abm']['album_list_size']
    assigns["albums"].each do |album|
      assert_equal 1, album.base_user_id
    end
  end
  
  define_method('test: friend_list は友達のアルバム一覧を表示する') do
    login_as :quentin
    
    get :friend_list
    albums = assigns["albums"]
    assert_not_nil albums
    assert albums.size <= AppResources['abm']['album_list_size']
    albums.each do |a|
      assert_equal UserRelationSystem::PUBLIC_LEVEL_ALL, a.public_level
    end
  end
end
