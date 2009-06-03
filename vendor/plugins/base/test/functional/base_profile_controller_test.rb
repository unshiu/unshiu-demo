
module BaseProfileControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
      end
    end
  end
  
  define_method('test: index は自分のプロフィールを表示する') do 
    login_as :quentin
    
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end
  
  define_method('test: index はログインしていなければログイン画面へ遷移する') do
    post :index
    assert_response :redirect
    assert_redirected_to :controller => 'base_user', :action => 'login', :return_to => "/base_profile"
  end
  
  define_method('test: show はプロフィールを表示する') do 
    login_as :quentin
    
    post :show, :id => 2 # base_user_id = 2 のユーザを表示する
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["user"])
    assert_equal(assigns["user"], BaseUser.find(2))
  end
  
  define_method('test: edit はプロフィール変更画面を表示する') do 
    login_as :quentin
    
    post :edit
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: update はプロフィールの更新処理を実行する') do 
    login_as :quentin
    
    post :update, 
         :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'test update introduction'}

    assert_response :redirect
    assert_redirected_to :controller => 'base_user_config', :action => :index

    base_profile = BaseProfile.find(:first, :conditions => [' base_user_id = 1 '])
    assert_not_nil(base_profile)
    assert_equal(base_profile.introduction, 'test update introduction') # 指定パラメータで更新されている
  end
  
  define_method('test: update はプロフィールの名前は空でも更新できる。') do 
    login_as :quentin
    
    post :update, :profile => {:name => ''}

    assert_response :redirect
    assert_redirected_to :controller => 'base_user_config', :action => :index

    base_profile = BaseProfile.find(:first, :conditions => [' base_user_id = 1 '])
    assert_not_nil(base_profile)
    assert_equal(base_profile.name, '') 
  end
  
  define_method('test: update はvalidateに通らないプロフィールの更新は edit 画面へ戻す。') do 
    login_as :quentin
    
    name = "あ" * 10000
    post :update, :profile => {:name => name}

    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: image はプロフィール画像アップロード画面を表示する。') do 
    login_as :quentin
    
    get :image
    
    assert_response :success
    assert_template 'image'
    
    assert_not_nil(assigns["base_profile"])
  end
  
  define_method('test: image_upload はプロフィール画像アップロード実行をする。') do 
    login_as :quentin
    
    update_path = RAILS_ROOT + "/test/tmp/file_column/base_profile/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    image = uploaded_file(file_path("file_column/base_profile/image/1/logo.gif"), 'image/gif', 'logo.gif')
    
    post :image_upload, :upload_file => {:image => image}, :id => 1
    
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    new_image = BaseProfile.find(1).image
    assert_not_nil(new_image) # 画像が設定されている
    assert_equal(File.basename(new_image), "logo.gif")
  end
end