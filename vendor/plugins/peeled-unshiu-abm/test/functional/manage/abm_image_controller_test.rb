
module Manage
  
  module AbmImageControllerTestModule
  
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

    def test_index
      login_as :quentin
    
      get :index
      assert_response :success
      assert_template "list"
    end

    def test_list
      login_as :quentin
    
      get :list
      assert_response :success
    
      images = assigns["images"]
    
      assert_instance_of PagingEnumerator, images
    
      images.each do |image|
        assert_instance_of AbmImage, image
      end
    end

    def test_show
      login_as :quentin
    
      get :show, :id => @image1
      assert_response :success
    
      image = assigns["image"]
    
      assert_instance_of AbmImage, image
      assert_equal @image1, image
    end
  
    def test_delete_confirm
      login_as :quentin
    
      get :show, :id => @image1
      assert_response :success
    
      image = assigns["image"]
    
      assert_instance_of AbmImage, image
      assert_equal @image1, image
    end
  
    def test_delete
      login_as :quentin
    
      post :delete, :id => @image1
      assert_response :redirect
      assert_redirected_to :controller => "manage/abm_album", :action => :show, :id => @image1.abm_album_id
    
      assert_raise(ActiveRecord::RecordNotFound) do
        AbmImage.find @image1
      end
    end
  
    def test_delete_cancel
      login_as :quentin
    
      post :delete, :id => @image1, :cancel => "cancel"
      assert_response :redirect
      assert_redirected_to :action => :show, :id => @image1.id

      # 消されていないことを確認
      image = AbmImage.find @image1
      assert_not_nil image
      assert_instance_of AbmImage, image
      assert_equal @image1, image
    end
  end
end
