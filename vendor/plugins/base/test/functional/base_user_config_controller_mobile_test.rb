
module BaseUserConfigControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_friends
        fixtures :dia_diaries
      end
    end
  end

  define_method('test: 登録情報変更画面を表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index_mobile'
  end
  
  define_method('test: 基本情報変更画面を表示する') do 
    login_as :quentin
    
    post :edit
    assert_response :success
    assert_template 'edit_mobile'
  end
  
  define_method('test: 基本情報変更確認画面を表示する') do 
    login_as :quentin
    
    post :update_confirm, :base_user => { :receive_system_mail_flag => 'true', :receive_mail_magazine_flag => 'true',
                                          :message_accept_level => 0},
                          :dia_diary => { :default_public_level => 0}
    assert_response :success
    assert_template 'update_confirm_mobile'
  end
  
  define_method('test: 基本情報変更実行処理') do 
    login_as :quentin
    
    post :update, :base_user => { :receive_system_mail_flag => 'false', :receive_mail_magazine_flag => 'false',
                                  :message_accept_level => 0},
                  :dia_diary => { :default_public_level => 0}
    
    assert_response :redirect
    assert_redirected_to :action => 'update_done'
    
    base_user = BaseUser.find_by_id(1)
    assert_equal(base_user.receive_system_mail_flag, false)
    assert_equal(base_user.receive_mail_magazine_flag, false)
    
    dia_diary = DiaDiary.find(:first, :conditions => [' base_user_id = 1 '])
    assert_equal(dia_diary.default_public_level, 0)
  end
  
  define_method('test: 基本情報変更実行処理のキャンセル') do 
    login_as :quentin
    
    post :update, :base_user => { :receive_system_mail_flag => 'false', :receive_mail_magazine_flag => 'false',
                                  :message_accept_level => 0},
                  :dia_diary => { :default_public_level => 0},
                  :cancel => 'true'
    
    assert_response :success
    assert_template 'edit_mobile'
    
    # 更新されてないことを確認
    base_user = BaseUser.find_by_id(1)
    assert_not_equal(base_user.receive_system_mail_flag, false)
    assert_not_equal(base_user.receive_mail_magazine_flag, false)
    
    dia_diary = DiaDiary.find(:first, :conditions => [' base_user_id = 1 '])
    assert_not_equal(dia_diary.default_public_level, 0)
  end
  
  define_method('test: 端末IDの設定確認画面を表示') do 
    login_as :quentin
    
    post :uid_set_confirm
    assert_response :success
    assert_template 'uid_set_confirm_mobile'
  end
  
  define_method('test: 端末IDの設定実行') do 
    login_as :quentin
    
    post :uid_set
    assert_response :redirect
    assert_redirected_to :action => 'uid_set_done'
    
    base_user = BaseUser.find(1)
    assert_equal(base_user.crypted_uid, BaseUser.encrypt_uid("012345678912345"))
  end
  
  define_method('test: 端末IDの設定実行をしようとするがuidを取得できないので設定画面へ戻る') do 
    @request.env["HTTP_USER_AGENT"] = "DoCoMo/2.0 SH903i(c100;TB;W24H16)" if @request.user_agent =~ /DoCoMo/
    @request.env["HTTP_USER_AGENT"] = "SoftBank/1.0/910T/TJ001 " if @request.user_agent =~ /SoftBank/
    @request.env["HTTP_X_UP_SUBNO"] = nil
    @request.env["HTTP_X_JPHONE_UID"] = nil
    
    login_as :quentin
    
    post :uid_set
    assert_response :redirect
    assert_redirected_to :action => 'uid_set_confirm'
  end
  
  define_method('test: メールアドレス変更入力画面を表示') do 
    login_as :quentin
    
    post :mail_reset_input
    assert_response :success
    assert_template 'mail_reset_input_mobile'
  end
  
  define_method('test: メールアドレス変更確認画面を表示') do 
    login_as :quentin
    
    post :mail_reset_confirm, :new_mail_address => 'testtesttest@drecom.co.jp'
    assert_response :success
    assert_template 'mail_reset_confirm_mobile'
  end
  
  define_method('test: メールアドレス変更確認画面を表示しようとするがメールアドレスが不正な値なので入力画面へ戻る') do 
    login_as :quentin
    
    post :mail_reset_confirm, :new_mail_address => 'testtesttest-drecom.co.jp'
    assert_response :success
    assert_template 'mail_reset_input_mobile'
  end
  
  define_method('test: メールアドレス変更用URLを送る') do 
    login_as :quentin
    
    post :mail_reset_send, :new_mail_address => 'testtesttest@drecom.co.jp'
    assert_response :redirect
    assert_redirected_to :action => 'mail_reset_send_done'
  end
  
  define_method('test: メールアドレス変更用URLを送る処理をキャンセルする') do 
    login_as :quentin
    
    post :mail_reset_send, :new_mail_address => 'testtesttest@drecom.co.jp', :cancel => 'true'
    assert_response :success
    assert_template 'mail_reset_input_mobile'
  end
  
  define_method('test: メールアドレス変更処理を実行する') do 
    
    post :mail_reset, :id => 'activation-twelve'
    assert_response :redirect
    assert_redirected_to :action => 'mail_reset_done'
    
    base_user = BaseUser.find_by_id(12)
    assert_equal(base_user.email, 'mail_reset@drecom.co.jp') # new_email が emailに書き変わっている
    assert_not_equal(base_user.login, 'mail_reset@drecom.co.jp') # loginIDはemailに引きずられてかわらない
  end
  
  define_method('test: メールアドレス変更処理を実行しようとするが既に有効なメールアドレスが設定されているのでエラーとなる') do 
    
    post :mail_reset, :id => 'activation-thirteen'
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
  end
end