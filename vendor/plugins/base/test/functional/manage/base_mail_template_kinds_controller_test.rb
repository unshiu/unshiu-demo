

module Manage::BaseMailTemplateKindsControllerTestModule
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
  
  define_method('test: メールテンプレート種類一覧を確認する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_not_nil assigns(:base_mail_template_kinds)
  end
  
  define_method('test: メールテンプレート種類一覧を確認する(list)') do 
    login_as :quentin

    get :list
    assert_response :success
    assert_not_nil assigns(:base_mail_template_kinds)
  end
  
  define_method('test: メールテンプレート種類詳細を確認する(list)') do 
    login_as :quentin

    get :show, :id => 1
    assert_response :success
    assert_not_nil assigns(:base_mail_template_kind)
  end
end
