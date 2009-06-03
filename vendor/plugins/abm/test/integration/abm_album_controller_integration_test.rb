require "#{File.dirname(__FILE__)}/../test_helper"

module AbmAlbumControllerIntegrationTestModule
  
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
   
  define_method('test: 自分のアルバムではないアルバムを削除しようとしてのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "abm_album/delete", :id => 2
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-02001"
  end
  
  define_method('test: アクセス権限のないユーザがアルバムをみようとしたのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "ten", :password => "test"

    post "abm_album/show", :id => 5
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "U-02002"
  end
end