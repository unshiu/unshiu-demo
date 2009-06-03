require File.dirname(__FILE__) + '/../test_helper'

module PrfControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :cmm_images
        fixtures :prf_profiles
        fixtures :prf_question_sets  
        fixtures :prf_question_set_partials  
        fixtures :prf_questions
        fixtures :prf_choices
        fixtures :prf_answers
        fixtures :prf_images
      end
    end
  end

  define_method('test: index は自分のプロフィールページを表示する') do 
    login_as :quentin
    
    get :index
    assert_response :redirect 
    assert_redirected_to :action => 'show', :id => 1
  end
  
  define_method('test: show プロフィール個別ページを表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: show はプロフィール個別ページは非ログイン時でも閲覧可能') do 
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: show はプロフィール個別ページを表示する、公開状態が未設定なので自分にだけ公開にする') do 
    login_as :ten
    
    # 事前確認：プロフィール未作成
    prf_profile = PrfProfile.find(:first, :conditions => ['base_user_id = 10'])
    assert_nil prf_profile
    
    post :show, :id => 10
    assert_response :success
    assert_template 'show'
    
    prf_profile = PrfProfile.find(:first, :conditions => ['base_user_id = 10'])
    assert_equal prf_profile.public_level, 5 # 自分だけ公開
  end

  define_method('test: edit はプロフィール編集ページを表示する') do 
    login_as :quentin
    
    post :edit
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: update はプロフィール編集保存を実行する') do 
    login_as :quentin
    
    post :update, :q => { "1" => 1, "2" => 1, "3" => 1, "4" => "住所", "5" => "save profile" },
                  :prf_profile => { :public_level => 3 }
                
    assert_response :redirect 
    assert_redirected_to :action => 'show', :id => 1
    
    prf_answer = PrfAnswer.find(:first, :conditions => [' prf_question_id = 5 and prf_profile_id = 1'])
    assert_equal prf_answer.body, "save profile" # 更新されている
    
    prf_profile = PrfProfile.find(:first, :conditions => [' base_user_id = 1'])
    assert_equal prf_profile.public_level, 3 # 更新されている
  end
  
  
  define_method('test: image はプロフィール画像アップロード画面を表示する。') do 
    login_as :quentin

    get :image

    assert_response :success
    assert_template 'image'

    assert_not_nil(assigns["prf_profile"])
  end

  define_method('test: image_upload はプロフィール画像アップロード実行をする。') do 
    login_as :quentin

    update_path = RAILS_ROOT + "/test/tmp/file_column/prf_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    image = uploaded_file(file_path("file_column/prf_image/image/1/logo.gif"), 'image/gif', 'logo.gif')

    post :image_upload, :upload_file => {:image => image}, :id => 1

    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1

    new_image = PrfProfile.find(1).prf_image.image
    assert_not_nil(new_image) # 画像が設定されている
    assert_equal(File.basename(new_image), "logo.gif")
  end
   
end
