require File.dirname(__FILE__) + '/../test_helper'

module PntControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :pnt_masters
        fixtures :pnt_points
      end
    end
  end
  
  define_method('test: ポイント情報をもつユーザでポイントtop画面を表示する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_template 'index_mobile'
  end
  
  define_method('test: ポイント情報をもたないユーザでもポイントtop画面を表示する') do 
    login_as :ten

    get :index
    assert_response :success
    assert_template 'index_mobile'
  end
  
  define_method('test: ポイント個別履歴を表示する') do 
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
    assert_template 'show_mobile'
    
  end
  
  define_method('test: ポイント履歴は本人でなければ閲覧できない') do 
    login_as :ten
    
    get :show, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code 'U-07001'
    
  end
  
end
