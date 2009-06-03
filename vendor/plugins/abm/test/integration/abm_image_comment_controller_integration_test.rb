require "#{File.dirname(__FILE__)}/../test_helper"

module AbmImageCommentControllerIntegrationTestModule
  
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
  
  define_method('test: アクセス権限のないユーザがアルバム画像のコメントをみようとしたのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "five", :password => "test"

    post "abm_image_comment/comments", :id => 6
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "U-02003"
  end
  
  define_method('test: 削除権限（日記の所有者か，コメントを書いた人）がないアルバム画像のコメントを削除しようとしたでエラー画面へ遷移する') do 
    post "base_user/login", :login => "five", :password => "test"

    post "abm_image_comment/confirm_delete_comment", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "U-02004"
  end
  
  define_method('test: 削除権限（日記の所有者か，コメントを書いた人）がないアルバム画像のコメントを削除実行しようとしたでエラー画面へ遷移する') do 
    post "base_user/login", :login => "five", :password => "test"

    post "abm_image_comment/delete_comment", :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'

    follow_redirect!

    assert_equal assigns(:error_code), "U-02004"
  end
  
end