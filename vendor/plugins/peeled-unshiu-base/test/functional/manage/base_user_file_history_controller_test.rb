
module Manage::BaseUserFileHistoryControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_profiles
        fixtures :base_friends
        fixtures :base_favorites
        fixtures :base_carriers
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :base_user_file_histories
      end
    end
  end
  
  define_method('test: csv出力結果ポータルは一覧ページを取得する') do 
    login_as :quentin
  
    get :index
    assert_response :redirect 
    assert_redirected_to :action => 'list'
    
  end

  define_method('test: csv出力結果一覧ページを取得する') do 
    login_as :quentin
  
    get :list
    assert_response :success
    assert_template 'list'
    
    assert_not_nil assigns(:histories)
  end
  
  define_method('test: csvファイルをダウンロードする') do 
    backup = AppResources[:base][:user_csv_file_path]
    AppResources[:base][:user_csv_file_path] = "test/file"
    
    login_as :quentin
  
    get :download, :id => 2
    assert_response :success
    
    AppResources[:base][:user_csv_file_path] = backup # ほかのテストに影響がないようにもどす
  end  
  
end
