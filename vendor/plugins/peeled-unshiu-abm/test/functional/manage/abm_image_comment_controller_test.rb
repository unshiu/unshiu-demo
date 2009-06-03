
module Manage
  
  module AbmImageCommentControllerTestModule
  
    class << self
      def included(base)
        base.class_eval do
          include TestUtil::Base::PcControllerTest

          fixtures :base_users
          fixtures :base_user_roles
          fixtures :base_friends
          fixtures :abm_albums
          fixtures :abm_images
          fixtures :abm_image_comments
        end
      end
    end

    def test_delete_confirm
      login_as :quentin
    
      get :delete_confirm, :id => @comment1
      assert_response :success
    
      comment = assigns["comment"]
    
      assert_instance_of AbmImageComment, comment
      assert_equal = @comment1, comment
    end
  
    def test_delete
      login_as :quentin
    
      get :delete, :id => @comment1
      assert_response :redirect
      assert_redirected_to :controller => "manage/abm_image", :action => :show, :id => @comment1.abm_image_id
    
      assert_not_nil flash[:notice]
      deleted = AbmImageComment.find(@comment1)
      assert_not_nil deleted.invisibled_by_manager? # 削除した管理者ユーザがかえるので
    end
  
    def test_delete_cancel
      login_as :quentin
    
      get :delete, :id => @comment1, :cancel => "cancel"
      assert_response :redirect
      assert_redirected_to :controller => "manage/abm_image", :action => :show, :id => @comment1.abm_image_id
    
      assert_nil flash[:notice]
    
      comment = AbmImageComment.find(@comment1)
    
      assert_not_nil comment
      assert_equal @comment1, comment
    end
    
  end
end
