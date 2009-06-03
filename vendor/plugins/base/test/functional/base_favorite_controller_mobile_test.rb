
module BaseFavoriteControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_favorites
      end
    end
  end
  
  define_method('test: Favoriteユーザ一覧を表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: Favoriteユーザ追加確認画面を表示する') do 
    login_as :quentin
    
    post :add_confirm, :id => 3 # base_user_id = 3 のユーザを追加する
    assert_response :success
    assert_template 'add_confirm_mobile'
  end
  
  define_method('test: Favoriteユーザ追加確認画面を表示しようとするが自分自身を追加しようとしているのでエラー') do 
    login_as :quentin
    
    post :add_confirm, :id => 1 # base_user_id = 1 のユーザを追加する
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: Favoriteユーザ追加実行する') do 
    login_as :quentin
    
    # 事前条件確認：まだfavoriteではない
    base_favorite = BaseFavorite.find(:first, :conditions => [' base_user_id = 1 and favorite_id = 3'])
    assert_nil base_favorite 
    
    post :add, :id => 3 # base_user_id = 3 のユーザを追加する
    assert_response :redirect
    assert_redirected_to :action => 'add_done'
    
    after_base_favorite = BaseFavorite.find(:first, :conditions => [' base_user_id = 1 and favorite_id = 3'])
    assert_not_nil after_base_favorite # 関係が生成されている
  end
  
  define_method('test: Favoriteユーザ追加実行しようとするが、既にお気に入りなのでエラーへ遷移') do 
    login_as :quentin
    
    post :add, :id => 2 # base_user_id = 2 のユーザを追加する
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: Favoriteユーザ追加実行のキャンセル') do 
    login_as :quentin
    
    post :add, :id => 3, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :controller => 'base_profile', :action => 'show'
  end
  
  define_method('test: Favoriteユーザ削除の確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 2 # base_user_id = 2 のユーザを削除する
    assert_response :success
    assert_template 'delete_confirm_mobile'
  end
  
  define_method('test: Favoriteユーザ削除の確認画面を表示しようとするがまだお気に入りではないのでエラー画面へ遷移') do 
    login_as :quentin
    
    post :delete_confirm, :id => 9 # base_user_id = 9 のユーザを削除する
    assert_response :redirect
    assert_redirect_with_error_code "U-01003"
  end
  
  define_method('test: Favoriteユーザ削除実行をする') do 
    login_as :quentin
    
    post :delete, :id => 1 # base_favorite の id = 1 の関係を削除する
    assert_response :redirect
    assert_redirected_to :action => 'delete_done'
    
    after_base_favorite = BaseFavorite.find(:first, :conditions => [' base_user_id = 1 and favorite_id = 2'])
    assert_nil after_base_favorite # 関係が削除されている
  end
  
  define_method('test: Favoriteユーザ削除の実行をしようとするがまだお気に入りではないのでエラー画面へ遷移') do 
    login_as :quentin
    
    post :delete, :id => 9 # base_user_id = 9 のユーザを削除する
    assert_response :redirect
    assert_redirect_with_error_code "U-01022"
  end
  
  define_method('test: Favoriteユーザ削除実行をキャンセル') do 
    login_as :quentin
    
    post :delete, :id => 1, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    after_base_favorite = BaseFavorite.find(:first, :conditions => [' base_user_id = 1 and favorite_id = 2'])
    assert_not_nil after_base_favorite # キャンセルしたので関係は削除されていない
  end
  
end