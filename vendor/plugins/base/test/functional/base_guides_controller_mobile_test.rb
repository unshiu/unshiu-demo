
module BaseGuidesControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_profiles
      end
    end
  end
  
  define_method('test: ガイドページを表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index_mobile'
  end
  
  define_method('test: ガイドページはログインしていなくても閲覧できる') do 
    
    post :index
    assert_response :success
    assert_template 'index_mobile'
  end
  
end