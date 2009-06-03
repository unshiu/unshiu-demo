require File.dirname(__FILE__) + '/../test_helper'
   
module DiaEntryControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        
        fixtures :base_users
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :dia_entries_abm_images
        fixtures :abm_images
        fixtures :abm_albums
      end
    end
  end
 
  define_method('test: show は日記記事を表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
  define_method('test: show は閲覧権限がない日記記事を表示しようとするとエラー画面へ遷移する') do 
    login_as :three
    
    post :show, :id => 8
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: show はコメントを指定されたorder順（古い順）で表示する') do
    login_as :quentin

    DiaEntryComment.record_timestamps = false
    comment = DiaEntryComment.create({:body => "oldest comment", :base_user_id => 1, :dia_entry_id => 1,
                                     :created_at => Time.now - 1.year, :updated_at => Time.now - 1.year})
    DiaEntryComment.record_timestamps = true

    post :show, :id => 1, :comment_order => "asc" # 古い順
    assert_response :success
    assert_template 'show'

    assert_not_nil(assigns['comments'])

    assert_equal(assigns['comments'].to_a[0].body, "oldest comment")
    before_topic = assigns['comments'].to_a[0].created_at
    assigns['comments'].each do |topic|
     assert(topic.created_at >= before_topic)
     before_topic = topic.created_at
    end
  end
  
  define_method('test: show はコメントを指定されたorder順（新しい順）で表示する') do
    login_as :quentin

    DiaEntryComment.record_timestamps = false
    comment = DiaEntryComment.create({:body => "newest comment", :base_user_id => 1, :dia_entry_id => 1,
                                     :created_at => Time.now + 1.year, :updated_at => Time.now + 1.year})
    DiaEntryComment.record_timestamps = true

    post :show, :id => 1, :comment_order => "desc" # 新着順
    assert_response :success
    assert_template 'show'

    assert_not_nil(assigns['comments'])

    assert_equal(assigns['comments'].to_a[0].body, "newest comment")
    before_topic = assigns['comments'].to_a[0].created_at
    assigns['comments'].each do |topic|
     assert(topic.created_at <= before_topic)
     before_topic = topic.created_at
    end
  end
  
  define_method('test: list は日記記事一覧画面を表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list'
    
    assert_not_nil(assigns["recent_dia_entries"])
    assert_not_nil(assigns["recent_dia_entry_comments"])
  end
  
  define_method('test: friend_list は友達の記事日記記事一覧を返す') do 
    login_as :quentin
    
    post :friend_list
    assert_response :success
    assert_template 'friend_list'
  end
  
  define_method('test: commented_list は自分がコメントした記事一覧を表示する') do 
    login_as :quentin
    
    post :commented_list
    assert_response :success
    assert_template 'commented_list'
  end
  
  define_method('test: show は日記記事を表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["recent_dia_entries"])
    assert_not_nil(assigns["recent_dia_entry_comments"])
  end
  
  define_method('test: 日記記事新規作成画面を表示する') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new'
    
    assert_not_nil(assigns["abm_albums"])
  end
  
  define_method('test: 日記記事新規作成を実行し、日記一覧画面へ遷移する') do 
    login_as :quentin
    
    assert_difference 'DiaEntry.count', 1 do
      post :create, :dia_entry => { :title => 'dia_etnry_controller_test create title', 
                                    :body => 'dia_etnry_controller_test create body',
                                    :public_level => 1 }
    end
    
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  end
  
  define_method('test: 日記記事新規作成でtitleを入力しなかったので入力画面へ戻る') do 
    login_as :quentin
    
    assert_difference 'DiaEntry.count', 0 do
      post :create, :dia_entry => { :title => '', 
                                    :body => 'dia_etnry_controller_test create body',
                                    :public_level => 1 }
    end
    
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 日記記事を下書きで保存し、日記一覧画面へ遷移する') do 
    login_as :quentin
    
    assert_difference 'DiaEntry.count', 1 do
      post :create, :dia_entry => { :title => 'dia_etnry_controller_test draft!', 
                                    :body => 'dia_etnry_controller_test create body',
                                    :public_level => 1 },
                    :draft => 'true'
    end
    
    dia_entry = DiaEntry.find_by_title("dia_etnry_controller_test draft!")
    assert_not_nil(dia_entry)
    assert_equal(dia_entry.draft_flag, true) # 下書きフラグあり
        
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  end
  
  define_method('test: 日記記事の編集画面を表示する') do 
    login_as :quentin
    
    post :edit, :id => 4
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: 日記記事の編集画面を表示しようとするが、自分の記事でないのでエラー画面を表示') do 
    login_as :aaron
    
    post :edit, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 日記記事の更新実行をする') do 
    login_as :quentin
    
    post :update, :id => 1, :dia_entry => { :title => 'dia_etnry_controller_test update title', 
                                            :body => 'dia_etnry_controller_test update body' }
    assert_response :redirect 
    assert_redirected_to :action => 'list'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test update title' "])
    assert_not_nil dia_entry # 登録されている
  end
  
  define_method('test: 画像付き日記記事の更新実行をする') do 
    login_as :quentin
    
    post :update, :id => 1, :dia_entry => { :title => 'dia_etnry_controller_test update title', 
                                            :body => 'dia_etnry_controller_test update body' },
                            :images => { 1 => 'true', 2 => 'true' }
    assert_response :redirect 
    assert_redirected_to :action => 'list'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test update title' "])
    assert_not_nil dia_entry # 登録されている
    
    dia_entries_abm_image = DiaEntriesAbmImage.find(:all, :conditions => [ " dia_entry_id = #{dia_entry.id} "])
    assert_equal dia_entries_abm_image.length, 2 # 画像が関連付けされている
  end
  
  define_method('test: 画像付き日記記事の更新実行をしようとするが、自分のもち画像以外が紛れ込んでいるためエラー画面を表示する') do 
    login_as :aaron
    
    post :update, :id => 2, :dia_entry => { :title => 'dia_etnry_controller_test update title', 
                                            :body => 'dia_etnry_controller_test update body' },
                            :images => { 1 => 'true', 2 => 'true' }
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test update title' "])
    assert_nil dia_entry # 登録されていない
  end
  
  define_method('test: 日記記事の更新をしようとするが、タイトルが未入力なため編集画面に戻る') do 
    login_as :quentin
    
    post :update, :id => 4, :dia_entry => { :title => '', 
                                                    :body => 'dia_etnry_controller_test update_confirm body',
                                                    :public_level => 1}
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: 日記記事を削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm'
  end
  
  define_method('test: 日記記事を削除する確認画面を表示しようとするが自分の日記ではないのでエラー画面へ遷移する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 2
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 日記記事の削除を実行する') do 
    login_as :quentin
    
    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'list'
    
    dia_entry = DiaEntry.find_by_id(1)
    assert_nil dia_entry # 削除されている
  end
  
  define_method('test: 日記記事の削除を実行しようとするが自分の日記ではないのでエラー画面へ遷移する') do 
    login_as :quentin
    
    post :delete, :id => 2
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    dia_entry = DiaEntry.find_by_id(2)
    assert_not_nil dia_entry # 削除されていない
  end
  
  define_method('test: 日記記事の削除を実行をキャンセル') do 
    login_as :quentin
    
    post :delete, :id => 1, :cancel => 'true', :cancel_to => "/dia_entry/list"
    assert_response :redirect 
    assert_redirected_to :action => 'list'
  end

  define_method('test: delete_draft は下書きの日記記事の削除を実行する') do 
    login_as :quentin
    
    post :delete_draft, :id => 5 # id = 5 は下書きの記事
    assert_response :redirect 
    assert_redirected_to :action => 'draft_list'
    
    dia_entry = DiaEntry.find_by_id(5)
    assert_nil dia_entry # 削除されている
  end
  
  define_method('test: delete_draft はキャンセルボタンを押されると下書きの日記記事の削除を実行をキャンセルする') do 
    login_as :quentin
    
    post :delete_draft, :id => 5, :cancel => 'true' # id = 5 は下書きの記事
    assert_response :redirect 
    assert_redirected_to :action => 'edit' # 戻るのは編集ページ
    
    dia_entry = DiaEntry.find_by_id(5)
    assert_not_nil dia_entry # 削除されていない
  end
  
end
