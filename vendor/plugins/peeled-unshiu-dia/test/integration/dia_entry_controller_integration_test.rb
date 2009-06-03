require "#{File.dirname(__FILE__)}/../test_helper"

module DiaEntryControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :dia_entries_abm_images
        fixtures :abm_images
        fixtures :abm_albums
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: 日記ID指定で日記下書き一覧画面を表示しようとするが、本人のものではないのでエラーへ遷移する') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "dia_entry/draft_list", :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04003"
  end
  
  define_method('test: 日記記事の編集画面を表示しようとするが、自分の記事でないのでエラー画面を表示') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "dia_entry/edit", :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04004"
  end
  
  define_method('test: 日記記事を表示しようとするが日記が存在しないのでがないのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "three", :password => "test"
    
    post "dia_entry/show", :id => 9999
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04005"
  end
  
  define_method('test: 日記記事の個別画像を表示しようとするが記事IDと画像IDに関連がないのでエラー画面へ遷移する') do 
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "dia_entry/show_image", :id => 1, :image => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04006"
  end
  
  define_method('test: 画像付きの日記記事を下書きで投稿しようとするが自分の画像でないものが含まれており、エラー') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "dia_entry/confirm", :dia_entry => { :title => 'dia_etnry_controller_test confirm title', 
                                              :body => 'dia_etnry_controller_test confirm body' }, 
                              :draft => 'true',
                              :images => { 1 => 'true', 2 => 'true' }
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04007"
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test confirm title' "])
    assert_nil dia_entry # 登録されていない
  end
  
  define_method('test: 個別アルバムを表示しようとするが、自分のアルバムではないので表示できない') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "dia_entry/album_show", :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
    
    assert_equal assigns(:error_code), "U-04008"
  end

end