
module AbmImageCommentControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :abm_albums
        fixtures :abm_images
        fixtures :abm_image_comments
      end
    end
  end
  
  define_method('test: コメント一覧画面はログインしていないと閲覧できない。') do
    login_required_test :comments
  end
  
  define_method('test: ある画像のコメント一覧画面を表示する。') do
    login_as :quentin
     
    get :comments, :id => 1
    assert_response :success
    
    assert_instance_of AbmImage, assigns["image"]
    assert_instance_of AbmAlbum, assigns["album"]
    
    assigns["comments"].each do |comment|
      assert_instance_of AbmImageComment, comment
      assert_equal 1, comment.abm_image_id
    end
  end
  
  define_method('test: 他人に公開されていない画像コメントは表示できない。') do
    login_as :five
     
    get :comments, :id => 6
    assert_response :redirect
    assert_redirect_with_error_code("U-02003")
  end
  
  define_method('test: update_remote はログインしていないとできない') do
    login_required_test :update_remote
  end
  
  define_method('test: update_remote は画像に対するコメントを実行する') do
    login_as :quentin
    
    image = AbmImage.find_by_id(1)
    
    post :update_remote, :id => image, :comment => { :body => "NEW COMMENT" }
    assert_response :success
    assert_rjs :visual_effect, :highlight, "abm_image_comment_message"
    
    assert_not_nil(assigns["abm_image_comments"])
    assert_equal "NEW COMMENT", assigns["comment"].body
    image_comment = AbmImageComment.find_by_body("NEW COMMENT")
    assert_not_nil(image_comment)
  end
  
  define_method('test: update_remote は内容に問題がある場合は投稿できなく、その理由を表示する') do
    login_as :quentin
    
    image = AbmImage.find_by_id(1)
    
    post :update_remote, :id => image, :comment => { :body => "" }
    assert_response :success
    assert_rjs :visual_effect, :highlight, "abm_image_comment_message"
    
    image_comment = AbmImageComment.find_by_body("")
    assert_nil(image_comment)
  end
  
  define_method('test: コメント削除確認画面はログインしていないと閲覧できない') do
    login_required_test :confirm_delete_comment
  end
  
  define_method('test: コメント削除確認画面を表示する') do
    login_as :quentin
    
    get :confirm_delete_comment, :id => 1
    assert_response :success
    
    assert_instance_of AbmImageComment, assigns["comment"]
    assert_instance_of AbmImage, assigns["image"]
    
    assert_equal AbmImageComment.find_by_id(1), assigns["comment"]
    assert_equal AbmImage.find_by_id(1), assigns["image"]
  end
  
  define_method('test: 削除権限がないコメント削除確認画面を表示しようとするとエラー画面へ遷移する') do
    login_as :aaron
    
    get :confirm_delete_comment, :id => 1
    assert_response :redirect
    assert_redirect_with_error_code("U-02004")
  end
  
  define_method('test: アルバム画像のコメントをコメントを書いた本人が削除する') do
    login_as :quentin
    
    post :delete_comment, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => :abm_image, :action => :show, :id => AbmImageComment.find_by_id(1).abm_image_id
    
    comment = AbmImageComment.find_by_id(1)
    assert_not_nil(comment)
    assert_equal(comment.invisibled_by, 1)
  end
  
  define_method('test: アルバム画像のコメントをアルバム所有者が削除する') do
    login_as :aaron
  
    post :delete_comment, :id => 3
    assert_response :redirect
    assert_redirected_to :controller => :abm_image, :action => :show, :id => AbmImageComment.find_by_id(3).abm_image_id
    
    comment = AbmImageComment.find_by_id(3)
    assert_not_nil(comment)
    assert_not_nil(comment.invisibled_by) 
  end
  
  define_method('test: アルバム画像のコメント削除をキャンセルする') do
    login_as :quentin
    
    abm_image_id = AbmImageComment.find_by_id(1).abm_image_id
    
    post :delete_comment, :id => abm_image_id, :cancel => "true", :cancel_to => "/abm_image/show/#{abm_image_id}"
    assert_response :redirect
    assert_redirected_to :controller => :abm_image, :action => :show, :id => abm_image_id
    
    comment = AbmImageComment.find_by_id(1)
    assert_not_nil(comment)
    assert_nil(comment.invisibled_by)
  end
  
private

  def login_required_test(action)
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_image_comment/#{action}"
  end

end
