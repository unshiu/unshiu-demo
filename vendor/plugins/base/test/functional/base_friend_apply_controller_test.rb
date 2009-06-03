
module BaseFriendApplyControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_ng_words
        fixtures :base_mail_template_kinds
        fixtures :base_mail_templates
      end
    end
  end
  
  define_method('test: 友達申請の新規登録画面を表示する') do 
    login_as :quentin
    
    post :new, :id => 4 # base_user_id = 4 と友達になる
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 友達申請の新規登録画面を表示しようとするが自分自身と登録しようとしているのでエラー画面へ遷移') do 
    login_as :quentin
    
    post :new, :id => 1 # base_user_id = 1 と友達になる
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 友達申請の処理実行をする') do 
    login_as :quentin
    
    post :create, :id => 4, :apply_message => "meesage" # base_user_id = 4 と友達になる
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 4'])
    assert_not_nil base_friend # 友達関係が存在する
    assert_equal base_friend.status, BaseFriend::STATUS_APPLYING # ステータスは申請中
  end
  
  define_method('test: 友達申請の処理実行をしようとするが自分自身なのでエラー') do 
    login_as :quentin
    
    post :create, :id => 1 # base_user_id = 1 と友達になる
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 1'])
    assert_nil base_friend # エラーなので関係は当然存在しない
  end
  
  define_method('test: create は友達申請の処理実行をする際、メッセージが5000文字以上だったら申請メッセージ入力画面へ戻る') do 
    login_as :quentin
    
    post :create, :id => 4, :apply_message => "あ" * 5001
    assert_response :success
    assert_template 'new'
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 4'])
    assert_nil base_friend # 友達関係は存在しない
  end
  
  define_method('test: 友達申請の処理実行のキャンセル') do 
    login_as :quentin
    
    post :create, :id => 4, :cancel => 'true' # base_user_id = 4 と友達になる
    assert_response :success
    assert_template 'new'
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 4'])
    assert_nil base_friend # キャンセルしたので友達関係が存在しない
  end
  
  define_method('test: 友達申請中リストが０件の場合正常に表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: 友達申請中リストが１件以上ある場合正常に表示する') do 
    login_as :aaron
    
    post :list
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: 申請された友達申請を受理するかどうかの画面を表示する') do 
    login_as :three
    
    post :permit_or_deny, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :success
    assert_template 'permit_or_deny'
  end
  
  define_method('test: 申請された友達申請を受理するかどうかの画面を表示しようとするが、回答者ではなのでエラー画面へ遷移する') do 
    login_as :ten
    
    post :permit_or_deny, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 申請された友達申請を受理実行をする') do 
    login_as :three
    
    # 事前確認：まだ承認前
    base_friend = BaseFriend.find_by_id(3)
    assert_not_nil base_friend # 友達関係が存在する
    assert_equal base_friend.status, BaseFriend::STATUS_APPLYING # ステータスは申請中
    
    post :permit, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :controller => :base_friend_apply, :action => 'list'
    
    after_base_friend = BaseFriend.find_by_id(3)
    assert_not_nil after_base_friend # 友達関係が存在する
    assert_equal after_base_friend.status, BaseFriend::STATUS_FRIEND # ステータスは友達！
  end
  
  define_method('test: 申請された友達申請を受理実行をしようとするが、申請をうけた人ではないのでエラーを表示') do 
    login_as :quentin
    
    post :permit, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 申請された友達申請の拒否を実行をする') do 
    login_as :three
    
    # 事前確認：まだ承認前
    base_friend = BaseFriend.find_by_id(3)
    assert_not_nil base_friend # 友達関係が存在する
    assert_equal base_friend.status, BaseFriend::STATUS_APPLYING # ステータスは申請中
    
    post :deny, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :controller => :base_friend_apply, :action => 'list'
    
    after_base_friend = BaseFriend.find_by_id(3)
    assert_nil after_base_friend # 友達関係は削除されている
  end
  
  define_method('test: 申請された友達申請の拒否を実行をしようとするが、申請をうけた人ではないのでエラーを表示') do 
    login_as :quentin
    
    post :deny, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
end