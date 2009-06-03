
module BaseNoticeControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_notices
      end
    end
  end

  define_method('test: お知らせ一覧を表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: お知らせ詳細を表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
end