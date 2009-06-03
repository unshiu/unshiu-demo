
module AbmImageControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :abm_albums
        fixtures :abm_images
        fixtures :abm_image_comments
      end
    end
  end
  
  define_method('test: 画像を表示する') do
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
    
    abm_image = AbmImage.find_by_id(1)
    
    assert_instance_of AbmImage, assigns["image"]
    assert_equal assigns["image"].id, abm_image.id
    
    assigns["albums"].each do |album| 
      assert_instance_of AbmAlbum, album
      assert_equal album.base_user_id, 1 
    end
    assert_not_nil(assigns["abm_image_comments"])
    assert_not_nil(assigns["abm_image_nexts"])
    assert_not_nil(assigns["abm_image_previouses"])
  end

  define_method('test: 非ログイン時に画像を表示する') do
    get :show, :id => 1
    assert_response :success
    
    assert_not_nil(assigns["image"])
    assert_nil(assigns["albums"]) # 非ログイン時はアルバム情報はもっていない
  end
  
  define_method('test: upload_remote はファイルの一括アップロードする') do
    login_as :quentin
    
    before_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    update_path = RAILS_ROOT + "/test/tmp/file_column/abm_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    post :upload_remote, :Filedata => uploaded_file(file_path("file_column/abm_image/image/7/logo.gif"), 'image/gif', 'logo.gif'), 
                         :abm_album_id => 1
    assert_response :success
    
    assert_instance_of AbmImage, assigns["image"]
    
    after_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    assert_equal(before_count + 1, after_count)
  end
  
  define_method('test: upload はファイル個別にアップロードする') do
    login_as :quentin
    
    before_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    update_path = RAILS_ROOT + "/test/tmp/file_column/abm_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    image = uploaded_file(file_path("file_column/abm_image/image/7/logo.gif"), 'image/gif', 'logo.gif')
    
    post :upload, :upload_file => {:image => image}, :abm_album_id => 1
    assert_response :redirect
    assert_redirected_to :controller => :abm_album, :action => :show, :id => 1
    
    assert_instance_of AbmImage, assigns["image"]
    
    after_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    assert_equal(before_count + 1, after_count)
  end
  
  define_method('test: upload はアップロードするファイルが選択されてないとアップロード画面を表示する') do
    login_as :quentin
    
    post :upload, :upload_file => nil, :abm_album_id => 1
    assert_response :success
    assert_template "new"
  end
  
  define_method('test: edit は画像編集画面はログインしていないと表示できない') do
    login_required_test :edit
  end
  
  define_method('test: edit は画像編集画面を表示する') do
    login_as :quentin
    
    get :edit, :id => 1
    assert_response :success
    
    assert_instance_of AbmImage, assigns["image"]
    assert_equal AbmImage.find_by_id(1), assigns["image"]
  end
  
  define_method('test: update はログインしていないと更新処理できない') do
    login_required_test :update
  end
  
  define_method('test: update は更新処理を実行する') do
    login_as :quentin
            
    post :update, :id => 7, :image => {:title => "NEW TITLE", :body => "NEW BODY"}
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 7
    
    assert_equal assigns["image"], AbmImage.find_by_id(7)
    assert_equal(AbmImage.find_by_id(7).title, "NEW TITLE")
  end
  
  define_method('test: update は更新内容に問題があれば更新処理を実行せず編集画面へ戻る') do
    login_as :quentin
            
    post :update, :id => 1, :image => {:title => "", :body => "NEW BODY"} # タイトルがない
    assert_response :success
    assert_template "edit"
  end
  
  define_method('test: アルバム画像表紙を設定する') do
    login_as :quentin
    
    # 事前チェックアルバムの表紙に　abm_image_id = 2　の画像は設定されていない
    abm_image = AbmImage.find_by_id(2)
    assert_not_equal(abm_image.abm_album.cover_abm_image_id, 2)
    
    get :cover_album_image, :id => 2
    
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 2
    
    abm_image = AbmImage.find_by_id(2)
    assert_equal(abm_image.abm_album.cover_abm_image_id, 2)
  end
  
  define_method('test: アルバムの画像表紙を設定しようとするが画像が自分の持ち物でないのでエラー画面へ遷移する') do
    login_as :ten
    
    get :cover_album_image, :id => 2
    
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 2
    
    abm_image = AbmImage.find_by_id(2)
    assert_equal(abm_image.abm_album.cover_abm_image_id, 2)
  end
  
  define_method('test: アルバム間で画像を移動を実行する') do
    login_as :quentin
    
    get :move_album, :id => 7, :abm_album_id => 4
    
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 7
    assert_not_nil(flash[:notice])
    assert_equal 4, assigns["image"].abm_album_id
    
    image = AbmImage.find_by_id(7)
    assert_equal(image.abm_album_id, 4)
  end
  
  define_method('test: アルバム間で画像を移動しようとするが自分の画像ではないのでエラーになる') do
    login_as :four
    
    get :move_album, :id => 2, :abm_albumid => 3
    assert_response :redirect
    assert_redirect_with_error_code("U-02005")
  end
  
  define_method('test: 削除確認画面はログインしていないとできない') do
    login_required_test :confirm_delete
  end
  
  define_method('test: 削除確認画面を表示する') do
    login_as :quentin

    post :confirm_delete, :id => 1
    assert_response :success
  end

  define_method('test: 自分のが画像でない画像を削除しようとするとエラー画面へ遷移する') do
    login_as :quentin
    
    post :confirm_delete, :id => 4
    assert_response :redirect
    assert_redirect_with_error_code("U-02005")
  end
  
  define_method('test: 削除処理はログインしていないとできない') do
    login_required_test :delete
  end
  
  define_method('test: 削除処理を実行する') do
    login_as :quentin
    
    abm_album_id = AbmImage.find_by_id(1).abm_album_id
    get :delete, :id => 1
    assert_redirected_to :controller => :abm_album, :action => :show, :id => abm_album_id
    
    abm_image = AbmImage.find_by_id(1)
    assert_nil(abm_image) # 削除されている
  end
  
  define_method('test: 画像削除をキャンセルする') do
    login_as :quentin
    
    get :delete, :id => 1, :cancel => "cancel"
    
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
  end
  
private 

  def login_required_test(action)    
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_image/#{action}"
  end
    
end
