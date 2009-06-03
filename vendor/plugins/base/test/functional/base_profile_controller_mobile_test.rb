
module BaseProfileControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :ace_footmarks
      end
    end
  end
  
  define_method('test: show はプロフィールを表示する') do 
    login_as :quentin
    
    post :show, :id => 1 # base_user_id = 1 のユーザを表示する
    assert_response :success
    assert_template 'show_mobile'
    
    ace_footmark = AceFootmark.find_footmark("base_profile#show", 1, 1)
    assert_not_nil(ace_footmark) # 足跡基本情報が作成されている
  end
  
  define_method('test: show は非ログイン時でもプロフィールを表示する') do 
    post :show, :id => 1 # base_user_id = 1 のユーザを表示する
    assert_response :success
    assert_template 'show_mobile'
    
    ace_footmark = AceFootmark.find_footmark("base_profile#show", -1, 1)
    assert_not_nil(ace_footmark) # 足跡基本情報が作成されている
  end
  
  define_method('test: プロフィール画像投稿用アドレス確認ページを表示する') do 
    login_as :quentin
    
    post :mail, :id => 1 # base_user_id = 1 のユーザを表示する
    assert_response :success
    assert_template 'mail_mobile'
  end
  
  define_method('test: プロフィール新規設定ページを表示する') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: プロフィール新規設定確認ページを表示する') do 
    login_as :quentin
    
    post :confirm, :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'しょーかい'}
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: プロフィール新規設定確認ページを表示しようとするが、名前にNGワードがはいっているので登録画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :profile => {:name => 'NGワード:aaa', :birthday => '1900-01-01', :sex => 1, :civil_status => 0, :introduction => 'しょーかい'}
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: プロフィール新規設定確認ページを表示しようとするが、誕生日日付が不正なので登録画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :profile => {:name => 'なまえ', :birthday => '1999-30-99', :sex => 1, :civil_status => 0, :introduction => 'しょーかい'}
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: プロフィールの新規作成を実行する') do 
    login_as :ten
    
    post :create, :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'test create introduction'}
    assert_response :redirect
    assert_redirected_to :action => 'done'
    
    base_profile = BaseProfile.find(:first, :conditions => [' base_user_id = 10 '])
    assert_not_nil(base_profile)
    assert_equal(base_profile.introduction, 'test create introduction') # 指定パラメータで作成されている
  end
  
  define_method('test: 名前が空でもプロフィールの新規作成を実行できる') do 
    login_as :ten
    
    post :create, :profile => {:name => ''}
    assert_response :redirect
    assert_redirected_to :action => 'done'
    
    base_profile = BaseProfile.find(:first, :conditions => [' base_user_id = 10 '])
    assert_not_nil(base_profile) # 作成はされてない
  end
  
  define_method('test: プロフィールの新規作成を実行をキャンセル') do 
    login_as :ten
    
    post :create, 
         :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'test create introduction'},
         :cancel => 'true'
         
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: プロフィールの編集画面を表示する') do 
    login_as :quentin
    
    post :edit
    assert_response :success
    assert_template 'edit_mobile'
  end
  
  define_method('test: プロフィールの編集確認画面を表示する') do 
    login_as :quentin
    
    post :update_confirm, 
         :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'test update confirm introduction'}
    assert_response :success
    assert_template 'update_confirm_mobile'
  end
  
  define_method('test: プロフィールの編集確認画面を表示しようとするが、紹介文にNGワードが含まれているため前画面へ戻る') do 
    login_as :quentin
    
    post :update_confirm, 
         :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'NGワード:aaa'}
    assert_response :success
    assert_template 'edit_mobile'
  end
  
  define_method('test: プロフィールの更新処理を実行する') do 
    login_as :quentin
    
    post :update, 
         :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'test update introduction'}

    assert_response :redirect
    assert_redirected_to :action => 'update_done'

    base_profile = BaseProfile.find(:first, :conditions => [' base_user_id = 1 '])
    assert_not_nil(base_profile)
    assert_equal(base_profile.introduction, 'test update introduction') # 指定パラメータで更新されている
  end
  
  define_method('test: プロフィールの名前は空でも更新できる。') do 
    login_as :quentin
    
    post :update, :profile => {:name => '', :introduction => 'test update introduction'}

    assert_response :redirect
    assert_redirected_to :action => 'update_done'

    base_profile = BaseProfile.find(:first, :conditions => [' base_user_id = 1 '])
    assert_not_nil(base_profile)
    assert_equal(base_profile.introduction, 'test update introduction') 
  end
  
  define_method('test: プロフィールの更新処理のキャンセル') do 
    login_as :quentin
    
    post :update, 
         :profile => {:name => 'なまえ', :birthday => '19000101', :sex => 1, :civil_status => 0, :introduction => 'test update introduction'},
         :cancel => 'true'
         
    assert_response :success
    assert_template 'edit_mobile'

    base_profile = BaseProfile.find(:first, :conditions => [' base_user_id = 1 '])
    assert_not_nil(base_profile)
    assert_not_equal(base_profile.introduction, 'test update introduction') # キャンセルしたので更新されていない
    
  end
  
end