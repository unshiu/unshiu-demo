
module AbmImageCommentControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
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
    error = BaseError.find_by_error_code_use_default("U-02003")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
  define_method('test: コメント投稿画面はログインしていないと閲覧できない。') do
    login_required_test :new_comment
  end
  
  define_method('test: コメント投稿画面を表示する。') do
    login_as :quentin
    
    get :new_comment, :id => 1
    assert_response :success
    
    image = AbmImage.find_by_id(1)
    
    assert_instance_of AbmImage, assigns["image"]
    assert_instance_of AbmImageComment, assigns["comment"]
    assert_equal image, assigns["image"]
  end
  
  define_method('test: コメント投稿確認画面はログインしていないと閲覧できない。') do
    login_required_test :confirm_comment
  end
  
  define_method('test: コメント投稿確認画面を表示する。') do
    login_as :quentin
    
    comment = AbmImageComment.new do |album|
      album.body = "NEW COMMENT"  
    end
    
    get :confirm_comment, :id => 1, :comment => comment.attributes
    assert_response :success
    assert_template 'confirm_comment_mobile'
    
    image = AbmImage.find_by_id(1)
    
    assert_instance_of AbmImage, assigns["image"]
    assert_instance_of AbmImageComment, assigns["comment"]
    assert_equal image, assigns["image"]
    assert_equal "NEW COMMENT", assigns["comment"].body
  end
  
  define_method('test: コメント未入力の場合は投稿画面を表示する。') do
    login_as :quentin
    
    comment = AbmImageComment.new
    
    get :confirm_comment, :id => 1, :comment => comment.attributes
    assert_response :success
    assert_template 'new_comment_mobile'
  end
  
  define_method('test: 画像に対するコメントを実行はログインしていないとできない') do
    login_required_test :save_comment
  end
  
  define_method('test: 画像に対するコメントを実行する') do
    login_as :quentin

    comment = AbmImageComment.new do |comment|
      comment.body = "NEW COMMENT" 
    end
    
    image = AbmImage.find_by_id(1)
    
    post :save_comment, :id => image, :comment => comment.attributes
    assert_response :redirect
    assert_redirected_to :action => :save_comment_done, :id => 1
    
    assert_equal "NEW COMMENT", assigns["comment"].body
  end
  
  define_method('test: 画像に対するコメント完了画面はログインしていないとみれない') do
    login_required_test :save_comment_done
  end
  
  define_method('test: 画像に対するコメント完了画面を表示する') do
    login_as :quentin

    get :save_comment_done, :id => 1
    assert_response :success
    
    comment = AbmImageComment.find_by_id(1)
    assert_equal comment.abm_image, assigns["image"]
  end
  
  define_method('test: アルバム画像のコメントをコメントを書いた本人が削除する') do
    login_as :quentin
    
    post :delete_comment, :id => 1
    assert_response :redirect
    assert_redirected_to :action => :delete_comment_done, :id => 1
    
    comment = AbmImageComment.find_by_id(1)
    assert_not_nil(comment)
    assert_equal(comment.invisibled_by, 1)
  end
  
  define_method('test: アルバム画像のコメントをアルバム所有者が削除する') do
    login_as :aaron
  
    post :delete_comment, :id => 3
    assert_response :redirect
    assert_redirected_to :action => :delete_comment_done, :id => 1

    comment = AbmImageComment.find_by_id(3)
    assert_not_nil(comment)
    assert_not_nil(comment.invisibled_by) 
  end
  
  define_method('test: アルバム画像のコメント削除をキャンセルする') do
    login_as :quentin
    
    abm_image_id = AbmImageComment.find_by_id(1).abm_image_id
    
    post :delete_comment, :id => abm_image_id, :cancel => "true", :cancel_to => "/abm_image_comment/comments/#{abm_image_id}"
    assert_response :redirect
    assert_redirected_to :controller => :abm_image_comment, :action => :comments, :id => abm_image_id
    
    comment = AbmImageComment.find_by_id(1)
    assert_not_nil(comment)
    assert_nil(comment.invisibled_by)
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
    
    error = BaseError.find_by_error_code_use_default("U-02004")
    assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
  end
  
private

  def login_required_test(action)
    get action
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => "/abm_image_comment/#{action}"
  end

end
