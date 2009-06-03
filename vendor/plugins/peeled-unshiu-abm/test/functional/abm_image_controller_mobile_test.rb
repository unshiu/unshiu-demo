
module AbmImageControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
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
    
    assert_instance_of AbmImage, assigns["image"]
    assert_equal AbmImage.find_by_id(1).id, assigns["image"].id
    
    assigns["albums"].each do |album| 
      assert_instance_of AbmAlbum, album
      assert_equal 1, album.base_user_id
    end
  end

  define_method('test: 非ログイン時に画像を表示する') do
    get :show, :id => 1
    assert_response :success
    
    assert_not_nil(assigns["image"])
    assert_nil(assigns["albums"]) # 非ログイン時はアルバム情報はもっていない
  end
  
  define_method('test: 削除確認画面はログインしていないと閲覧できない') do
    login_required_test :confirm_delete
  end
  
  define_method('test: 削除確認画面を表示する') do
    login_as :quentin
    
    get :confirm_delete, :id => 1
    assert_response :success
    
    assert_instance_of AbmImage, assigns["image"]
    assert_equal AbmImage.find_by_id(1), assigns["image"]
  end
  
  define_method('test: 削除処理はログインしていないとできない') do
    login_required_test :delete
  end
  
  define_method('test: 削除処理を実行する') do
    login_as :quentin
    
    get :delete, :id => 1
    assert_redirected_to :action => :delete_done, :id => 1
    
    abm_image = AbmImage.find_by_id(1)
    assert_nil(abm_image) # 削除されている
    # TODO cancel test
  end
  
  define_method('test: 画像削除をキャンセルする') do
    login_as :quentin
    
    get :delete, :id => 1, :cancel => "cancel"
    
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
  end
  
  define_method('test: 削除完了画面はログインしていないと表示できない') do
    login_required_test :delete_done
  end
  
  define_method('test: 削除完了画面を表示する') do
    login_as :quentin
    
    get :delete_done, :id => 1
    assert_response :success
    
    assert_equal AbmAlbum.find_by_id(1), assigns["album"]
  end
  
  define_method('test: 画像編集画面はログインしていないと表示できない') do
    login_required_test :edit
  end
  
  define_method('test: 画像編集画面を表示する') do
    login_as :quentin
    
    get :edit, :id => 1
    assert_response :success
    
    assert_instance_of AbmImage, assigns["image"]
    assert_equal AbmImage.find_by_id(1), assigns["image"]
  end
  
  define_method('test: 編集確認画面はログインしていないと表示できない') do
    login_required_test :confirm_edit
  end
  
  define_method('test: 編集確認画面を表示する') do  
    login_as :quentin
    
    image = AbmImage.new
    image.title = "NEW TITLE"
    image.body  = "NEW BODY"
    
    get :confirm_edit, :id => 1, :image => image.attributes
    
    assert_instance_of AbmImage, assigns["image"]
    assert_equal "NEW TITLE", assigns["image"].title
    assert_equal "NEW BODY" , assigns["image"].body
    
    # DBの内容はまだ書き換わっていないことを確認
    image = AbmImage.find_by_id(1)
    assert_not_equal image.title, assigns["image"].title
    assert_not_equal image.body , assigns["image"].body
  end

  define_method('test: 削除確認画面はログインしていないと表示できない') do
    login_required_test :confirm_edit
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
    error = BaseError.find_by_error_code_use_default("U-02005")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
  define_method('test: 更新処理はログインしていないとできない') do
    login_required_test :update
  end
  
  define_method('test: update は更新要素の更新処理を実行する') do
    login_as :quentin
            
    post :update, :id => 7, :image => {:title => "NEW TITLE", :body => "NEW BODY"}
    assert_response :redirect
    assert_redirected_to :action => :update_done, :id => 7
    
    assert_equal assigns["image"], AbmImage.find_by_id(7)
    assert_equal(AbmImage.find_by_id(7).title, "NEW TITLE")
  end
  
  define_method('test: 更新完了画面はログインしていないと閲覧できない') do
    login_required_test :update_done
  end
  
  define_method('test: 更新完了画面を表示する') do
    login_as :quentin
    
    get :update_done, :id => 1
    assert_response :success
    
    assert_instance_of AbmImage, assigns["image"]
    assert_equal AbmImage.find_by_id(1), assigns["image"]
  end
  
  define_method('test: 自分の画像でない画像の更新完了画面を表示できない') do
    login_as :aaron
    
    get :update_done, :id => 1
    assert_response :redirect
    
    error = BaseError.find_by_error_code_use_default("U-02005")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
  define_method('test: アルバム間で画像を移動を実行する') do
    login_as :quentin
    
    get :move_album, :id => 1, :abm_album_id => 4
    assert_response :redirect
    assert_redirected_to :action => :move_album_done, :id => 1
    
    assert_equal 4, assigns["image"].abm_album_id
  end
  
  define_method('test: アルバム間で画像を移動しようとするが自分の画像ではないのでエラーになる') do
    login_as :four
    
    get :move_album, :id => 2, :abm_albumid => 3
    assert_response :redirect
    error = BaseError.find_by_error_code_use_default("U-02005")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
  define_method('test: アルバム間移動確認画面はログインしてなければみれない') do
    login_required_test :confirm_move_album
  end
  
  define_method('test: アルバム間移動確認画面を表示する') do
    login_as :quentin
    
    get :confirm_move_album, :abm_album_id => 2, :id => 1
    assert_response :success
    
    assert_equal 2, assigns["album"].id
    assert_equal AbmImage.find_by_id(1).id, assigns["image"].id
  end
  
  define_method('test: アルバム間移動完了画面はログインしてなければみれない') do
    login_required_test :move_album_done
  end
  
  define_method('test: アルバム間で移動完了画面を表示する') do
    login_as :quentin
    
    get :move_album_done, :id => 1
    assert_response :success
    
    assert_equal AbmImage.find_by_id(1), assigns["image"]
    assert_equal AbmAlbum.find_by_id(1), assigns["album"]
  end
  
  define_method('test: アルバム間で移動ができるのは権限があるユーザのみ') do
    login_as :five
    
    get :move_album_done, :id => 1
    
    assert_response :redirect
    error = BaseError.find_by_error_code_use_default("U-02005")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
private 

  def login_required_test(action)    
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_image/#{action}"
  end
  
end
