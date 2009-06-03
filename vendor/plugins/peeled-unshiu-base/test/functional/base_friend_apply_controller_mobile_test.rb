
module BaseFriendApplyControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_ng_words
        fixtures :base_mail_template_kinds
        fixtures :base_mail_templates
      end
    end
  end
  
  define_method('test: 友達申請中リストが０件の場合正常に表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: 友達申請中リストが１件以上ある場合正常に表示する') do 
    login_as :aaron
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: 友達申請の新規登録画面を表示する') do 
    login_as :quentin
    
    post :new, :id => 4 # base_user_id = 4 と友達になる
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 友達申請の新規登録画面を表示しようとするが自分自身と登録しようとしているのでエラー画面へ遷移') do 
    login_as :quentin
    
    post :new, :id => 1 # base_user_id = 1 と友達になる
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 友達申請の新規登録確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :id => 4, :apply_message => '申請メッセージ' # base_user_id = 4 と友達になる
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: 友達申請の新規登録確認画面を表示しようとするが申請メッセージが入力されていなかったので確認画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :id => 4, :apply_message => '' 
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 友達申請の新規登録確認画面を表示しようとするが申請メッセージにNGワードがはいっていたので確認画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :id => 4, :apply_message => 'NGワード:aaa' 
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 友達申請の処理実行をする') do 
    login_as :quentin
    
    post :create, :id => 4, :apply_message => "message" # base_user_id = 4 と友達になる
    assert_response :redirect
    assert_redirected_to :action => 'done'
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 4'])
    assert_not_nil base_friend # 友達関係が存在する
    assert_equal base_friend.status, BaseFriend::STATUS_APPLYING # ステータスは申請中
  end
  
  define_method('test: 友達申請の処理実行をしようとするが自分自身なのでエラー') do 
    login_as :quentin
    
    post :create, :id => 1, :apply_message => "message" # base_user_id = 1 と友達になる
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 1'])
    assert_nil base_friend # エラーなので関係は当然存在しない
  end
  
  define_method('test: 友達申請の処理実行のキャンセル') do 
    login_as :quentin
    
    post :create, :id => 4, :cancel => 'true' # base_user_id = 4 と友達になる
    assert_response :success
    assert_template 'new_mobile'
    
    base_friend = BaseFriend.find(:first, :conditions => ['base_user_id = 1 and friend_id = 4'])
    assert_nil base_friend # キャンセルしたので友達関係が存在しない
  end
  
  
  define_method('test: 申請された友達申請を受理するかどうかの画面を表示する') do 
    login_as :three
    
    post :permit_or_deny, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :success
    assert_template 'permit_or_deny_mobile'
  end
  
  define_method('test: 申請された友達申請を受理するかどうかの画面を表示しようとするが、回答者ではなのでエラー画面へ遷移する') do 
    login_as :ten
    
    post :permit_or_deny, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 申請された友達申請を受理する確認画面を表示する') do 
    login_as :three
    
    post :permit_confirm, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :success
    assert_template 'permit_confirm_mobile'
  end
  
  define_method('test: 申請された友達申請を受理する確認画面を表示しようとするが、既に受理されている関係なのでエラー画面を表示する') do 
    login_as :three
    
    post :permit_confirm, :id => 1 
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
    assert_redirected_to :action => 'permit_done'
    
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
  
  define_method('test: 申請された友達申請を受理実行のキャンセル') do 
    login_as :three
    
    post :permit, :id => 3, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => 'permit_or_deny'
    
    base_friend = BaseFriend.find_by_id(3)
    assert_not_nil base_friend # 友達関係が存在する
    assert_equal base_friend.status, BaseFriend::STATUS_APPLYING # キャンセルしたのでステータスは申請中
  end
  
  define_method('test: 申請された友達申請を拒否する確認画面を表示する') do 
    login_as :three
    
    post :deny_confirm, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :success
    assert_template 'deny_confirm_mobile'
  end
  
  define_method('test: 申請された友達申請を拒否する確認画面を表示しようとするが、既に処理されている関係なのでエラー画面を表示する') do 
    login_as :three
    
    post :deny_confirm, :id => 1 
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
    assert_redirected_to :action => 'deny_done'
    
    after_base_friend = BaseFriend.find_by_id(3)
    assert_nil after_base_friend # 友達関係は削除されている
  end
  
  define_method('test: 申請された友達申請の拒否を実行をしようとするが、申請をうけた人ではないのでエラーを表示') do 
    login_as :quentin
    
    post :deny, :id => 3 # base_friend id = 3 の関連を処理する
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 申請された友達申請を拒否実行のキャンセル') do 
    login_as :three
    
    post :deny, :id => 3, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => 'permit_or_deny'
    
    base_friend = BaseFriend.find_by_id(3)
    assert_not_nil base_friend # 友達関係が存在する
    assert_equal base_friend.status, BaseFriend::STATUS_APPLYING # キャンセルしたのでステータスは申請中
  end
  
end