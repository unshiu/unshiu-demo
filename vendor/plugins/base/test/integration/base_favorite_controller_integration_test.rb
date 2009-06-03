require "#{File.dirname(__FILE__)}/../test_helper"

module BaseFavoriteControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_favorites
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: Favoriteユーザ削除の確認画面を表示しようとするがまだお気に入りではないのでエラー画面へ遷移') do 
    quenin_login
    
    post "base_favorite/delete_confirm", :id => 9 # base_user_id = 9 のユーザを削除する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01003"
  end
  
  define_method('test: Favoriteユーザ削除実行しようとするがまだお気に入りではないのでエラー画面へ遷移') do 
    quenin_login
    
    post "base_favorite/delete", :id => 9 # base_favorite の id = 9 の関係を削除する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01022"
  end
  
  define_method('test: Favoriteユーザ追加実行しようとするが、既にお気に入りなのでエラー画面へ遷移') do 
    quenin_login
    
    post "base_favorite/add", :id => 2 # base_user_id = 2 のユーザを追加する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01004"
  end
  
  define_method('test: Favoriteユーザ追加確認画面を表示しようとするが自分自身を追加しようとしているのでエラー') do 
    quenin_login
    
    post "base_favorite/add_confirm", :id => 1 # base_user_id = 1 のユーザを追加する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01005"
  end
  
  private 
  
  def quenin_login
    post "base_user/login", :login => "quentin", :password => "test"
  end
end
