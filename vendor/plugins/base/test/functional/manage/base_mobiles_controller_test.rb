
module Manage::BaseMobilesControllerTestModule
  
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
  
  define_method('test: 対応機種一覧を表示する') do 
    login_as :quentin
  
    get :index
    assert_response :success
    assert_not_nil assigns(:jpmobile_carriers)
    assert_not_nil assigns(:mobiles_news)
  end
  
  define_method('test: キャリア情報を検索する') do 
    login_as :quentin
  
    post :search, :keyword => 'SH'
    assert_response :success
    assert_not_nil assigns(:jpmobile_devices)
    assert_not_equal(assigns(:jpmobile_devices).size, 0)
    
    assigns(:jpmobile_devices).each do |device|
      assert_match(/SH/, device.name)
    end
  end
  
end
