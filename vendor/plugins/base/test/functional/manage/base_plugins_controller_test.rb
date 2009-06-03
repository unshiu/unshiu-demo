
module Manage::BasePluginsControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
      end
    end
  end
  
  define_method('test: プラグイン一覧を確認する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_template 'index'
  end
  
  define_method('test: プラグイン詳細を確認する') do 
    login_as :quentin

    post :show, :id => 'base'
    
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:plugin_info)
    assert_not_nil assigns(:plugin_news)
  end
  
  define_method('test: プラグインのニュース一覧を表示する') do 
    login_as :quentin

    get :news
    
    assert_response :success
    assert_template 'news'
    assert_not_nil assigns(:plugin_news)
  end
  
end
