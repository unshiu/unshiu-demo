require "#{File.dirname(__FILE__)}/../test_helper"

module AbmImageControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :abm_albums
        fixtures :abm_images
        fixtures :abm_image_comments
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: アクセス権限のないユーザがアルバム画像を移動しようとしたのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "five", :password => "test"
    
    post "abm_image/move_album_done", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "U-02005"
  end
  
  define_method('test: アクセス権限のないユーザがアルバム画像を表示しようとしたのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "five", :password => "test"
    
    post "abm_image/show", :id => 6
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "U-02006"
  end
  
end