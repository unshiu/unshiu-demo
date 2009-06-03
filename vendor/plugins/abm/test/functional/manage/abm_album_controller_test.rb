
module Manage
  
  module AbmAlbumControllerTestModule
  
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
    
      albums = assigns["albums"]
    
      assert_instance_of PagingEnumerator, albums
      assert_equal 7, albums.size
      albums.each do |album|
        assert_instance_of AbmAlbum, album
      end
    end
  
    def test_show
      login_as :quentin
    
      get :show, :id => @album1
      assert_response :success
    
      album = assigns["album"]
    
      assert_instance_of AbmAlbum, album
      assert_equal @album1, album
    end
  
    def test_delete_confirm
      login_as :quentin
    
      get :delete_confirm, :id => @album1
      assert_response :success
    
      album = assigns["album"]
    
      assert_instance_of AbmAlbum, album
      assert_equal @album1, album
    end
  
    def test_delete
      login_as :quentin
    
      get :delete, :id => @album1
      assert_response :redirect
      assert_redirected_to :action => :list
    
      assert_not_nil flash[:notice]
    
      assert_raise(ActiveRecord::RecordNotFound) do
        AbmAlbum.find(@album1)
      end
    
    end
  
    def test_delete_cancel
      login_as :quentin
    
      get :delete, :id => @album1, :cancel => "cancel"
      assert_response :redirect
      assert_redirected_to :action => :show, :id => @album1.id
    
      # 削除されてないことを確認
      assert_equal AbmAlbum.find(@album1), @album1
    end
  
    private
    def login_required_test(action)
      get action
      assert_response :redirect
      assert_redirected_to :controller => :base_user, :action => :login
    end
  
  end
end
