require File.dirname(__FILE__) + '/../test_helper'

module PrfControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
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

  define_method('test: index は自分のプロフィールを表示する') do 
    login_as :quentin
    
    get :index
    assert_response :redirect 
    assert_redirected_to :action => 'show', :id => 1
  end
  
  define_method('test: プロフィール個別ページを表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show_mobile'
  end
  
  define_method('test: プロフィール個別ページは非ログイン時でも閲覧可能') do 
    post :show, :id => 1
    assert_response :success
    assert_template 'show_mobile'
  end
  
  define_method('test: プロフィール個別ページを表示する、公開状態が未設定なので自分にだけ公開にする') do 
    login_as :ten
    
    # 事前確認：プロフィール未作成
    prf_profile = PrfProfile.find(:first, :conditions => ['base_user_id = 10'])
    assert_nil prf_profile
    
    post :show, :id => 10
    assert_response :success
    assert_template 'show_mobile'
    
    prf_profile = PrfProfile.find(:first, :conditions => ['base_user_id = 10'])
    assert_equal prf_profile.public_level, 5 # 自分だけ公開
  end
  
  define_method('test: プロフィール画像投稿ページを表示する') do 
    login_as :quentin
    
    post :mail, :id => 1
    assert_response :success
    assert_template 'mail_mobile'
  end
  
  define_method('test: プロフィール編集ページを表示する') do 
    login_as :quentin
    
    post :edit
    assert_response :success
    assert_template 'edit_mobile'
  end
  
  define_method('test: プロフィール編集ページ確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :q => { "1" => 1, "2" => 1, "3" => 1, "4" => 1, "5" => 1, 12 => "ああああ" }
                   
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: プロフィール編集保存を実行する') do 
    login_as :quentin
    
    post :update, :q => { "1" => 1, "2" => 1, "3" => 1, "4" => "住所", "5" => "save profile" }
                
    assert_response :redirect 
    assert_redirected_to :action => 'done'
    
    prf_answer = PrfAnswer.find(:first, :conditions => [' prf_question_id = 5 and prf_profile_id = 1'])
    assert_equal prf_answer.body, "save profile" # 更新されている
  end
  
  define_method('test: プロフィール編集保存のキャンセル') do 
    login_as :quentin
    
    post :update, :q => { "1" => 1, "2" => 1, "3" => 1, "4" => "住所", "5" => "save profile" },
                  :cancel => 'true'
                
    assert_response :success
    assert_template 'edit_mobile' # 編集画面を表示する
  end
  
  define_method('test: 公開レベル設定ページを表示する') do 
    login_as :quentin
    
    post :public_level_edit
    assert_response :success
    assert_template 'public_level_edit_mobile'
    
    assert_not_nil(assigns['prf_profile'])
  end
  
  define_method('test: 公開レベル設定確認ページを表示する') do 
    login_as :quentin
    
    post :public_level_confirm, :prf_profile => { :public_level => 3 }
    assert_response :success
    assert_template 'public_level_confirm_mobile'
    
    assert_not_nil(assigns['prf_profile'])
    assert_equal(assigns['prf_profile'].public_level, 3)
  end
  
  define_method('test: 公開レベルを更新し完了ページを表示する') do 
    login_as :quentin
    
    post :public_level_update, :prf_profile => { :public_level => 3 }
    assert_response :redirect 
    assert_redirected_to :action => 'done'
    
    prf_profile = PrfProfile.find(:first, :conditions => [' base_user_id = 1'])
    assert_equal prf_profile.public_level, 3 # 更新されている
  end
  
  define_method('test: 公開レベルを更新をキャンセルする') do 
    login_as :quentin
    
    post :public_level_update, :cancel => "true",
                               :prf_profile => { :public_level => 3 }
    assert_response :success
    assert_template 'public_level_edit_mobile' # 編集画面を表示する
    
    prf_profile = PrfProfile.find(:first, :conditions => [' base_user_id = 1'])
    assert_not_equal prf_profile.public_level, 3 # 更新されていない
  end
end
