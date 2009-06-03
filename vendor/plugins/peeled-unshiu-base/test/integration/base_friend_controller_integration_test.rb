require "#{File.dirname(__FILE__)}/../test_helper"

module BaseFriendControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_errors
      end
    end
  end

  define_method('test: 友達として追加する確認画面を表示しようとするが自分自身を友達として追加しようとしているのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend/add_confirm", :id => 1 # base_user_id = 1 を友達として追加
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01012"
  end
  
  define_method('test: 友達として追加しようとするが、自分自身なのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend/add", :id => 1 # base_user_id = 1 を友達として追加
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01012"
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 1'])
    assert_nil base_friend # 友達関係が存在しない
  end
  
  define_method('test: 友達として追加しようとするが、既に友達なのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 2'])
    assert_not_nil base_friend # 友達関係が存在する
    
    post "base_friend/add", :id => 2 # base_user_id = 2 を友達として追加
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01010"
  end
  
  define_method('test: 友達ではない友達を削除する確認画面を表示するしたためエラー画面へ遷移') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend/delete_confirm", :id => 9 # base_user_id = 9 を友達から削除
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01014"
  end
  
  define_method('test: 友達の削除処理を実行しようとするが、関係のないユーザなので削除できずエラー画面へ遷移する') do 
    post "base_user/login", :login => "three", :password => "test"
    
    post "base_friend/delete", :id => 1 # base_friend id = 1 の友達関係を削除
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    after_base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 2'])
    assert_not_nil after_base_friend # エラーなので削除できず友達関係が存在している
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01014"
  end
  
end