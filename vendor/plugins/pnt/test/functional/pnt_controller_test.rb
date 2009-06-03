require File.dirname(__FILE__) + '/../test_helper'

module PntControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_menus
        fixtures :pnt_masters
        fixtures :pnt_points
      end
    end
  end
  
  define_method('test: ポイント情報をもつユーザでポイントtop画面を表示する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil(assigns["all_point"])
    assert_not_nil(assigns["pnt_points"])
    assert_not_nil(assigns["pnt_histories"])
  end
  
  define_method('test: ポイント情報をもたないユーザでもポイントtop画面を表示する') do 
    login_as :ten

    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil(assigns["all_point"])
    assert_not_nil(assigns["pnt_points"])
    assert_nil(assigns["pnt_histories"])  
  end
   
  define_method('test: ポイント情報をもつユーザでポイント個別表示画面を表示する') do 
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["all_point"])
    assert_not_nil(assigns["pnt_points"])
    assert_not_nil(assigns["pnt_histories"])
  end
  
  define_method('test: 自分のポイント以外の詳細を閲覧することはできない') do 
    login_as :ten
    
    get :show, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code 'U-07001'
  end
  
end
