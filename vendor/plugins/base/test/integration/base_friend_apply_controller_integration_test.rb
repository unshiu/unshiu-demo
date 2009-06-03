require "#{File.dirname(__FILE__)}/../test_helper"

module BaseFriendApplyControllerIntegrationTestModule

  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 友達申請の新規登録画面を表示しようとするが自分自身と登録しようとしているのでエラー画面へ遷移') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend_apply/new", :id => 1 # base_user_id = 1 と友達になる
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01006"
  end
  
  define_method('test: 申請された友達申請を受理するかどうかの画面を表示しようとするが、回答者ではなのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "ten", :password => "test"
    
    post "base_friend_apply/permit_or_deny", :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01007"
  end
  
  define_method('test: 申請された友達申請を受理実行をしようとするが、申請をうけた人ではないのでエラーを表示') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend_apply/permit", :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01007"
  end
  
  define_method('test: 申請された友達申請を拒否する確認画面を表示しようとするが、既に処理されている関係なのでエラー画面を表示する') do 
    post "base_user/login", :login => "three", :password => "test"
    
    post "base_friend_apply/deny_confirm", :id => 1 
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01008"
  end
  
  define_method('test: 申請された友達申請を許可する確認画面を表示しようとするが、既に処理されている関係なのでエラー画面を表示する') do 
    post "base_user/login", :login => "three", :password => "test"
    
    post "base_friend_apply/permit_confirm", :id => 1 
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01009"
  end
  
  define_method('test: 申請された友達申請の拒否を実行をしようとするが、申請をうけた人ではないのでエラーを表示') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend_apply/deny", :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01007"
  end
  
  define_method('test: 申請された友達申請の拒否を実行をしようとするが、申請をうけた人ではないのでエラーを表示') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend_apply/deny", :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01007"
  end
  
  define_method('test: 申請された友達申請を許可しようとするが、既に処理されている関係なのでエラー画面を表示する') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "base_friend_apply/create", :id => 1, :apply_message => "message" # base_user = 1 のユーザとの関係を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-01010"
  end
  
  define_method('test: 申請された友達申請を許可しようとするが、友達が存在しないので404画面を表示する') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "base_friend_apply/create", :id => 9999 # base_user = 9999 とのユーザ関係を処理する
    assert_response 404
  end
end