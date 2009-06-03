

module Manage::BaseMailTemplatesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_mail_templates
        fixtures :base_mail_template_kinds
      end
    end
  end
  
  
  define_method('test: メールテンプレート一覧を確認する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_not_nil assigns(:base_mail_templates)
  end
  
  define_method('test: メールテンプレートを新規作成する') do 
    login_as :quentin

    get :new
    assert_response :success
  end
  
  define_method('test: メールテンプレート作成の確認をする') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', 0 do
      post :create_confirm, :base_mail_template => { :base_mail_template_kind_id => 1, :content_type => "text/plain", 
                                                     :subject => "new", :body => "body", :device_type => 1, :footer_flag => true}
    end
    
    assert_response :success
    assert_template "create_confirm"
  end
  
  define_method('test: メールテンプレート作成の確認をしようとするが必須入力がみたされてないので入力画面に戻る') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', 0 do
      post :create_confirm, :base_mail_template => { :base_mail_template_kind_id => 1, :content_type => "text/plain", 
                                                     :subject => "", :body => ""}
    end
    
    assert_response :success
    assert_template "new"
  end
  
  define_method('test: create はメールテンプレートを作成する') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', 1 do
      post :create, :base_mail_template => { :base_mail_template_kind_id => 1, :content_type => "text/plain", 
                                             :subject => "メールテンプレートを作成するテスト", :body => "body", :active_flag => true, :footer_flag => true,
                                             :device_type => 1}
    end
    
    mail_template = BaseMailTemplate.find_by_subject("メールテンプレートを作成するテスト")
    assert_not_nil(mail_template)
    assert_equal(mail_template.active_flag, false) # デフォルトでは有効ではない
      
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => mail_template.id
    
  end
  
  define_method('test: メールテンプレート作成はキャンセルボタンを押されたので実行しない') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', 0 do # 増加してない
      post :create, :base_mail_template => { :base_mail_template_kind_id => 1, :content_type => "text/plain", 
                                             :subject => "new", :body => "body", :active_flag => true, :footer_flag => true, 
                                             :device_type => 1},
                    :cancel => true
    end
    
    assert_response :success 
    assert_template 'new'
  end
  
  define_method('test: メールテンプレートを確認する') do 
    login_as :quentin

    get :show, :id => 1
    
    assert_response :success
  end

  define_method('test: メールテンプレートを編集する') do 
    login_as :quentin

    get :edit, :id => 1
    
    assert_response :success
  end
  
  define_method('test: メールテンプレート編集の確認をする') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', 0 do
      post :update_confirm, :id => 1, 
                            :base_mail_template => { :base_mail_template_kind_id => 1, :content_type => "text/plain", 
                                                     :subject => "update", :body => "update body"}
    end
    
    assert_response :success
  end
  
  define_method('test: update はメールテンプレート更新する') do 
    login_as :quentin

    put :update, :id => 1, :base_mail_template => { :subject => 'test update'}
    
    assert_response :redirect 
    assert_redirected_to manage_base_mail_template_path(1)
    
    base_mail_templates = BaseMailTemplate.find(1)
    assert_equal(base_mail_templates.subject, 'test update')
  end

  define_method('test: update はメールテンプレート更新するが、同じ送信デバイスに既にアクティブなテンプレートがあれば既存のテンプレートは下書きになる') do 
    login_as :quentin

    # 事前確認：アクティブな同デバイステンプレートがある
    pc_base_mail_template = BaseMailTemplate.find(2)
    assert_equal(pc_base_mail_template.device_type, 2)
    assert_equal(pc_base_mail_template.active_flag, true)
    
    put :update, :id => 1, :base_mail_template => { :device_type => 2}
    
    assert_response :redirect 
    assert_redirected_to manage_base_mail_template_path(1)
    
    base_mail_templates = BaseMailTemplate.find(1)
    assert_equal(base_mail_templates.device_type, 2)
    
    pc_base_mail_template = BaseMailTemplate.find(2)
    assert_equal(pc_base_mail_template.device_type, 2)
    assert_equal(pc_base_mail_template.active_flag, false)
  end
  
  define_method('test: メールテンプレート更新はキャンセルボタンを押されたので実行しない') do 
    login_as :quentin

    put :update, :id => 1, :base_mail_template => { :subject => 'test update'}, :cancel => true
    
    assert_response :success 
    
    base_mail_templates = BaseMailTemplate.find(1)
    assert_not_equal(base_mail_templates.subject, 'test update') # 更新されていない
  end
  
  define_method('test: active_confirm はメールテンプレートを有効にする確認画面を表示する') do 
    login_as :quentin

    base_mail_template = BaseMailTemplate.new({ :base_mail_template_kind_id => 2, :content_type => "text/plain", 
                                                :subject => "new", :body => "new new", :active_flag => false, :footer_flag => true,
                                                :device_type => 1})
    base_mail_template.save # 新規作成されたもの
      
    post :active_confirm, :id => base_mail_template.id
    assert_response :success
  end
  
  define_method('test: active はメールテンプレートを有効にする') do 
    login_as :quentin

    base_mail_template = BaseMailTemplate.new({ :base_mail_template_kind_id => 2, :content_type => "text/plain", 
                                                :subject => "new", :body => "new new", :active_flag => false, :footer_flag => true,
                                                :device_type => 1})
    base_mail_template.save # 新規作成されたもの
      
    post :active, :id => base_mail_template.id
    
    assert_response :redirect 
    assert_redirected_to manage_base_mail_template_kind_path(2)
    
    after_base_mail_templates = BaseMailTemplate.find_active_mail_templates_by_action('send_registration_url')
    assert(after_base_mail_templates.size > 0)
    
    template = false
    after_base_mail_templates.each do |after_base_mail_template|
      if after_base_mail_template.device_type == 1
        assert_not_equal(base_mail_templates, after_base_mail_templates) # 有効テンプレートがかわっている
        template = true 
      end
    end
    assert(template)
  end
  
  define_method('test: active はメールテンプレートを有効はキャンセルボタンを押されたので実行しない') do 
    login_as :quentin

    before_base_mail_templates = BaseMailTemplate.find_active_mail_templates_by_action('already_registed')
    
    base_mail_template = BaseMailTemplate.new({ :base_mail_template_kind_id => 3, :content_type => "text/plain", 
                                                :subject => "new", :body => "new new", :active_flag => false, :footer_flag => true,
                                                :device_type => 1 })
    base_mail_template.save # 新規作成されたもの
    
    post :active, :id => base_mail_template.id, :cancel => true
    
    assert_response :redirect 
    assert_redirected_to manage_base_mail_template_kind_path(3)
    
    after_base_mail_template = BaseMailTemplate.find_active_mail_template_by_action_name_and_device_type('already_registed', 1)
    assert_not_nil(after_base_mail_template)
  
    assert_not_equal(base_mail_templates, after_base_mail_template) # 有効テンプレートがかわっていない
  end
  
  define_method('test: メールテンプレートを削除確認画面を表示する') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', 0 do
      delete :destroy_confirm, :id => 1
    end

    assert_response :success
  end
  
  define_method('test: メールテンプレートを削除する') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', -1 do
      delete :destroy, :id => 1
    end

    assert_response :redirect 
    assert_redirected_to manage_base_mail_template_kind_path(1)
  end
  
  
  define_method('test: メールテンプレート削除はキャンセルボタンを押されたので実行しない') do 
    login_as :quentin

    assert_difference 'BaseMailTemplate.count', 0 do
      delete :destroy, :id => 1, :cancel => true
    end

    assert_response :redirect 
    assert_redirected_to manage_base_mail_template_kind_path(1)
  end
  
  define_method('test: send_test_confirm はメールテンプレートのテスト送信確認画面を表示する') do 
    login_as :quentin

    base_mail_template = BaseMailTemplate.new({ :base_mail_template_kind_id => 2, :content_type => "text/plain", 
                                                :subject => "send test", :body => "send test", :active_flag => false, :footer_flag => true,
                                                :device_type => 1})
    base_mail_template.save!
      
    post :send_test_confirm, :id => base_mail_template.id, 
                             :forms_base_mail_template_send_test_form => { :mail_address => 'test@unshiu.drecom.jp'}
    assert_response :success
  end
  
  define_method('test: send_test_confirm はメールテンプレートのテスト送信確認画面を表示しようとするとがメールドレスが不正な値なので入力画面へ戻る') do 
    login_as :quentin

    base_mail_template = BaseMailTemplate.new({ :base_mail_template_kind_id => 2, :content_type => "text/plain", 
                                                :subject => "send test", :body => "send test", :active_flag => false, :footer_flag => true,
                                                :device_type => 1 })
    base_mail_template.save 
      
    post :send_test_confirm, :id => base_mail_template.id, 
                             :forms_base_mail_template_send_test_form => { :mail_address => 'testunshiu.drecom.jp'}
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: send_test はメールテンプレートのテスト送信実行をする') do 
    login_as :quentin

    base_mail_template = BaseMailTemplate.new({ :base_mail_template_kind_id => 2, :content_type => "text/plain", 
                                                :subject => "send test", :body => "send test", :active_flag => false, :footer_flag => true,
                                                :device_type => 1})
    base_mail_template.save
    
    post :send_test, :id => base_mail_template.id, 
                             :forms_base_mail_template_send_test_form => { :mail_address => 'test@unshiu.drecom.jp'}
    
    assert_response :redirect 
    assert_redirected_to manage_base_mail_template_kind_path(2)      
    
  end
  
  define_method('test: send_test はメールテンプレートのテスト送信実行をキャンセルする') do 
    login_as :quentin

    base_mail_template = BaseMailTemplate.new({ :base_mail_template_kind_id => 2, :content_type => "text/plain", 
                                                :subject => "send test", :body => "send test", :active_flag => false, :footer_flag => true,
                                                :device_type => 1 })
    base_mail_template.save
     
    post :send_test, :id => base_mail_template.id, 
                     :forms_base_mail_template_send_test_form => { :mail_address => 'test@unshiu.drecom.jp'},
                     :cancel => true

    assert_response :success
    assert_template 'show'    
  end
end
