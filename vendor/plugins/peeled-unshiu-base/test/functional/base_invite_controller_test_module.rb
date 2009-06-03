
module BaseInviteControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_ng_words
        fixtures :base_mail_template_kinds
        fixtures :base_mail_templates
      end
    end
  end
  
  define_method('test: 新規ユーザ招待画面を表示する') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new_mobile'
  end

  define_method('test: 新規ユーザ招待確認画面を表示する') do 
    login_as :quentin
    
    post :confirm, :mail_address => 'aaaa@drecom.co.jp', :invite_message => '招待するよ！'
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: 新規ユーザ招待確認画面を表示しようとするが、メッセージが未入力なので登録画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :mail_address => 'aaaa@drecom.co.jp', :invite_message => ''
    assert_response :success
    assert_template 'new_mobile'
  end 
  
  define_method('test: 新規ユーザ招待確認画面を表示しようとするが、メールアドレスが未入力なので登録画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :mail_address => '', :invite_message => '招待するよ!!'
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 新規ユーザ招待確認画面を表示しようとするが、メッセージにNGワードが含まれているので登録画面へ戻る') do 
    login_as :quentin
    
    post :confirm, :mail_address => 'aaaa@drecom.co.jp', :invite_message => 'NGワード:aaa'
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 新規ユーザ招待を実行する') do 
    login_as :quentin
    
    post :create, :mail_address => 'aaaa@drecom.co.jp', :invite_message => '招待するよ!!'
    assert_response :redirect
    assert_redirected_to :action => 'done'
  end
  
  define_method('test: 新規ユーザ招待を実行しようとするが、既に登録済みのメールアドレス。ただしセキュリティを考慮して処理完了画面は表示する') do 
    login_as :quentin
    
    post :create, :mail_address => 'mobilesns-dev@devml.drecom.co.jp', :invite_message => '招待するよ!!'
    assert_response :redirect
    assert_redirected_to :action => 'done'
  end
  
end