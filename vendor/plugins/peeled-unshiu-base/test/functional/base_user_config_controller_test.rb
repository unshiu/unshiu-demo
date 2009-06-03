
module BaseUserConfigControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_friends
        fixtures :dia_diaries
      end
    end
  end

  define_method('test: 設定確認画面を表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns["base_user"])
    
  end
  
  define_method('test: 設定を更新する') do 
    login_as :quentin
    
    post :update, :base_user => { :receive_system_mail_flag => 'false', :receive_mail_magazine_flag => 'false',
                                  :message_accept_level => 0},
                  :dia_diary => { :default_public_level => 0}
    
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_not_nil(flash[:notice])
    
    base_user = BaseUser.find_by_id(1)
    assert_equal(base_user.receive_system_mail_flag, false)
    assert_equal(base_user.receive_mail_magazine_flag, false)
    
    dia_diary = DiaDiary.find(:first, :conditions => [' base_user_id = 1 '])
    assert_equal(dia_diary.default_public_level, 0)
  end
  
  define_method('test: mail_reset_input はメールアドレス変更入力画面を表示') do 
    login_as :quentin
    
    post :mail_reset_input
    assert_response :success
    assert_template 'mail_reset_input'
  end
  
  define_method('test: mail_reset_send メールアドレス変更用URLを送る') do 
    login_as :quentin
    
    post :mail_reset_send, :new_mail_address => 'testtesttest@drecom.co.jp'
    assert_response :redirect
    assert_redirected_to :controller => 'base_user_config', :action => 'index'
  end
  
  define_method('test: mail_reset_send でメールアドレス変更用URLを送ろうとするがしようとするがメールアドレスが不正な値なので入力画面へ戻る') do 
    login_as :quentin
    
    post :mail_reset_send, :new_mail_address => 'testtesttest-drecom.co.jp'
    assert_response :success
    assert_template 'mail_reset_input'
  end
  
  
  define_method('test: mail_reset_send はキャンセルボタンをおしたらメールアドレス変更用URLを送る処理をキャンセルする') do 
    login_as :quentin
    
    post :mail_reset_send, :new_mail_address => 'testtesttest@drecom.co.jp', :cancel => 'true'
    assert_response :success
    assert_template 'mail_reset_input'
  end
  
  define_method('test: mail_reset はメールアドレス変更処理を実行する') do 
    post :mail_reset, :id => 'activation-twelve'
    assert_response :redirect
    assert_redirected_to :controller => 'base_user_config', :action => "index"
    assert_not_nil(flash[:notice])
    
    base_user = BaseUser.find_by_id(12)
    assert_equal(base_user.email, 'mail_reset@drecom.co.jp') # new_email が emailに書き変わっている
    assert_not_equal(base_user.login, 'mail_reset@drecom.co.jp') # loginIDはemailに引きずられてかわらない
  end
  
  define_method('test: mail_reset は既に有効なメールアドレスが設定されているの場合はエラーとなる') do 
    post :mail_reset, :id => 'activation-thirteen'
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
    
end