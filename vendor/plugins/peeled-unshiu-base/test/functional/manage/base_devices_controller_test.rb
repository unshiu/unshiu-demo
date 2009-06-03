

module Manage::BaseDevicesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :jpmobile_carriers
        fixtures :jpmobile_devices
        fixtures :jpmobile_displays
        fixtures :jpmobile_ipaddresses
      end
    end
  end
  
  define_method('test: 機種詳細情報を表示する') do 
    login_as :quentin
  
    get :show, :id => 1
    assert_response :success
    assert_not_nil assigns(:jpmobile_device)
    
  end
  
  define_method('test: その機種での閲覧を許可するように設定する確認画面を表示する') do 
    login_as :quentin
  
    post :available_confirm, :id => 1
    assert_response :success
    
    assert_not_nil assigns(:jpmobile_device)
    assert_equal(assigns(:jpmobile_device).id, 1)
  end
  
  define_method('test: その機種での閲覧を許可') do 
    login_as :quentin
  
    post :available, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => :show, :id => 1
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.find(1)
    assert_equal(jpmobile_device.available_flag, true)
  end
  
  define_method('test: その機種での閲覧を許可をキャンセル') do 
    jpmobile_device = Jpmobile::Model::JpmobileDevice.find(1)
    jpmobile_device.available_flag = false
    jpmobile_device.save! # 不許可しておく
    
    login_as :quentin
  
    post :available, :id => 1, :cancel => true
    assert_response :redirect 
    assert_redirected_to :action => :show, :id => 1
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.find(1)
    assert_equal(jpmobile_device.available_flag, false) # キャンセルしたのでフラグは変化してない
  end
  
  define_method('test: その機種での閲覧を拒否するように設定する確認画面を表示する') do 
    login_as :quentin
  
    post :unavailable_confirm, :id => 1
    assert_response :success
    
    assert_not_nil assigns(:jpmobile_device)
    assert_equal(assigns(:jpmobile_device).id, 1)
  end
  
  define_method('test: その機種での閲覧を拒否') do 
    login_as :quentin
  
    post :unavailable, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => :show, :id => 1
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.find(1)
    assert_equal(jpmobile_device.available_flag, false)
  end
  
  define_method('test: その機種での閲覧拒否をキャンセル') do 
    login_as :quentin
  
    post :unavailable, :id => 1, :cancel => true
    assert_response :redirect 
    assert_redirected_to :action => :show, :id => 1
    
    jpmobile_device = Jpmobile::Model::JpmobileDevice.find(1)
    assert_equal(jpmobile_device.available_flag, true) # キャンセルしたのでフラグは変化してない
  end
end
