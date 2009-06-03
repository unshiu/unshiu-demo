require File.dirname(__FILE__) + '/../test_helper'
   
module DiaEntryControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        
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
 
  define_method('test: 日記記事一覧画面を表示する') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list_mobile'
  end
  
  define_method('test: 日記下書き一覧画面を表示する') do 
    login_as :quentin
    
    post :draft_list
    assert_response :success
    assert_template 'draft_list_mobile'
  end
  
  define_method('test: 日記ID指定で日記下書き一覧画面を表示する') do 
    login_as :quentin
    
    post :draft_list, :id => 1
    assert_response :success
    assert_template 'draft_list_mobile'
  end
  
  define_method('test: 日記ID指定で日記下書き一覧画面を表示しようとするが、本人のものではないのでエラーへ遷移する') do 
    login_as :aaron
    
    post :draft_list, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 自分がコメントした記事一覧を表示する') do 
    login_as :quentin
    
    post :commented_list
    assert_response :success
    assert_template 'commented_list_mobile'
  end
  
  define_method('test: 友達の記事日記記事一覧を返す') do 
    login_as :quentin
    
    post :friend_list
    assert_response :success
    assert_template 'friend_list_mobile'
  end
  
  define_method('test: 公開されている日記記事一覧を返す') do 
    login_as :quentin
    
    post :public_list
    assert_response :success
    assert_template 'public_list_mobile'
  end
  
  define_method('test: 記事を検索する') do 
    DiaEntry.clear_index!
    DiaEntry.reindex!
    
    login_as :quentin
    
    post :search
    assert_response :success
    assert_template 'search_mobile'
  end
  
  define_method('test: キーワードで記事を検索する') do 
    login_as :quentin
    
    post :search, :keyword => 'キーワード'
    assert_response :success
    assert_template 'search_mobile'
  end
  
  define_method('test: 日記記事を新規作成する') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 日記投稿用アドレス確認ページを表示する') do 
    login_as :quentin
    
    post :mail
    assert_response :success
    assert_template 'mail_mobile'
  end
  
  define_method('test: 日記記事の投稿確認ページを表示する') do 
    login_as :aaron
    
    post :confirm, :dia_entry => { :title => 'テスト投稿', :body => 'テストです。', :public_level => 1 }
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: 日記記事の投稿確認ページを表示しようとするが、タイトルが未入力なため投稿ページへ戻る') do 
    login_as :aaron
    
    post :confirm, :dia_entry => { :title => '', :body => 'テストです。', :public_level => 1 }
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: 日記記事を下書きで投稿する') do 
    login_as :aaron
    
    post :confirm, :dia_entry => { :title => 'dia_etnry_controller_test confirm title', 
                                   :body => 'dia_etnry_controller_test confirm body',
                                   :public_level => 1 }, 
                   :draft => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'draft_done'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test confirm title' "])
    assert_not_nil dia_entry # 登録されている
    assert_equal dia_entry.draft_flag, true # 下書きフラグはたっている
  end
  
  define_method('test: 画像付きの日記記事を下書きで投稿する') do 
    login_as :quentin
    
    post :confirm, :dia_entry => { :title => 'dia_etnry_controller_test confirm title', 
                                   :body => 'dia_etnry_controller_test confirm body',
                                   :public_level => 1 }, 
                   :draft => 'true',
                   :images => { 1 => 'true', 2 => 'true' }
    assert_response :redirect 
    assert_redirected_to :action => 'draft_done'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test confirm title' "])
    assert_not_nil dia_entry # 登録されている
    assert_equal dia_entry.draft_flag, true # 下書きフラグはたっている
    
    dia_entries_abm_image = DiaEntriesAbmImage.find(:all, :conditions => [ " dia_entry_id = #{dia_entry.id} "])
    assert_equal dia_entries_abm_image.length, 2 # 画像が関連付けされている
  end
  
  define_method('test: 画像付きの日記記事を下書きで投稿しようとするが自分の画像でないものが含まれており、エラー') do 
    login_as :aaron
    
    post :confirm, :dia_entry => { :title => 'dia_etnry_controller_test confirm title', 
                                   :body => 'dia_etnry_controller_test confirm body',
                                   :public_level => 1 }, 
                   :draft => 'true',
                   :images => { 1 => 'true', 2 => 'true' }
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test confirm title' "])
    assert_nil dia_entry # 登録されていない
  end
  
  define_method('test: 日記記事の作成実行処理') do 
    login_as :quentin
    
    post :create, :dia_entry => { :title => 'dia_etnry_controller_test create title', 
                                  :body => 'dia_etnry_controller_test create body',
                                  :public_level => 1 }
    assert_response :redirect 
    assert_redirected_to :action => 'done'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test create title' "])
    assert_not_nil dia_entry # 登録されている
  end
  
  define_method('test: 日記記事の作成をキャンセル') do 
    login_as :quentin
    
    post :create, :dia_entry => { :title => 'dia_etnry_controller_test create cancel title', 
                                  :body => 'dia_etnry_controller_test create cancel body', 
                                  :public_level => 1 },
                  :cancel => 'true'
    assert_response :success
    assert_template 'new_mobile'
                      
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test create cancel title' "])
    assert_nil dia_entry # 登録されていない
  end
  
  define_method('test: 画像付きの日記記事の作成実行処理') do 
    login_as :quentin
    
    post :create, :dia_entry => { :title => 'dia_etnry_controller_test create title', 
                                  :body => 'dia_etnry_controller_test create body',
                                  :public_level => 1 },
                  :images => { 1 => 'true' }
                  
    assert_response :redirect 
    assert_redirected_to :action => 'done'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test create title' "])
    assert_not_nil dia_entry # 登録されている
    
    dia_entries_abm_image = DiaEntriesAbmImage.find(:all, :conditions => [ " dia_entry_id = #{dia_entry.id} "])
    assert_equal dia_entries_abm_image.length, 1 # 画像が関連付けされている
  end
  
  define_method('test: 日記記事の編集画面を表示する') do 
    login_as :quentin
    
    post :edit, :id => 4
    assert_response :success
    assert_template 'edit_mobile'
  end
  
  define_method('test: 日記記事の編集画面を表示しようとするが、自分の記事でないのでエラー画面を表示') do 
    login_as :aaron
    
    post :edit, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 日記記事の編集確認画面を表示する') do 
    login_as :quentin
    
    post :update_confirm, :id => 4, :dia_entry => { :title => 'dia_etnry_controller_test update_confirm title', 
                                                    :body => 'dia_etnry_controller_test update_confirm body',
                                                    :public_level => 1 }
    assert_response :success
    assert_template 'update_confirm_mobile'
  end
  
  define_method('test: 日記記事の編集確認画面を表示しようとするが、タイトルが未入力なため編集画面に戻る') do 
    login_as :quentin
    
    post :update_confirm, :id => 4, :dia_entry => { :title => '', 
                                                    :body => 'dia_etnry_controller_test update_confirm body',
                                                    :public_level => 1}
    assert_response :success
    assert_template 'edit_mobile'
  end
  
  define_method('test: 日記記事の編集確認画面を表示しようとするが、自分の日記記事ではないのでエラー画面を表示する') do 
    login_as :aaron
    
    post :update_confirm, :id => 4, :dia_entry => { :title => 'dia_etnry_controller_test update_confirm title', 
                                                    :body => 'dia_etnry_controller_test update_confirm body' }
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 画像付き日記記事の編集確認画面を表示する') do 
    login_as :quentin
    
    post :update_confirm, :id => 4, 
                          :dia_entry => { :title => 'dia_etnry_controller_test update_confirm title', 
                                          :body => 'dia_etnry_controller_test update_confirm body',
                                          :public_level => 1},
                          :images => { 1 => 'true' }
    assert_response :success
    assert_template 'update_confirm_mobile'
  end
  
  define_method('test: 日記記事を編集し下書きで保存する') do 
    login_as :quentin
    
    post :update_confirm, :id => 1, 
                          :dia_entry => { :title => 'dia_etnry_controller_test update_confirm title', 
                                          :body => 'dia_etnry_controller_test update_confirm body',
                                          :public_level => 1},
                          :draft => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'draft_done'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test update_confirm title' "])
    assert_not_nil dia_entry # 登録されている
    assert_equal dia_entry.draft_flag, true # 下書きフラグはたっている
  end
  
  define_method('test: 画像付き日記記事を編集し下書きで保存する') do 
    login_as :quentin
    
    post :update_confirm, :id => 4, 
                          :dia_entry => { :title => 'dia_etnry_controller_test update_confirm title', 
                                          :body => 'dia_etnry_controller_test update_confirm body',
                                          :public_level => 1},
                          :images => { 1 => 'true', 2 => 'true' },
                          :draft => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'draft_done'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test update_confirm title' "])
    assert_not_nil dia_entry # 登録されている
    assert_equal dia_entry.draft_flag, true # 下書きフラグはたっている
    
    dia_entries_abm_image = DiaEntriesAbmImage.find(:all, :conditions => [ " dia_entry_id = #{dia_entry.id} "])
    assert_equal dia_entries_abm_image.length, 2 # 画像が関連付けされている
  end
  
  define_method('test: 日記記事の更新実行をする') do 
    login_as :quentin
    
    post :update, :id => 1, :dia_entry => { :title => 'dia_etnry_controller_test update title', 
                                            :body => 'dia_etnry_controller_test update body' }
    assert_response :redirect 
    assert_redirected_to :action => 'update_done'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test update title' "])
    assert_not_nil dia_entry # 登録されている
  end
  
  define_method('test: 画像付き日記記事の更新実行をする') do 
    login_as :quentin
    
    post :update, :id => 1, :dia_entry => { :title => 'dia_etnry_controller_test update title', 
                                            :body => 'dia_etnry_controller_test update body' },
                            :images => { 1 => 'true', 2 => 'true' }
    assert_response :redirect 
    assert_redirected_to :action => 'update_done'
    
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
  
  define_method('test: 日記記事の更新実行をキャンセルする') do 
    login_as :quentin
    
    post :update, :id => 4, :dia_entry => { :title => 'dia_etnry_controller_test update title', 
                                            :body => 'dia_etnry_controller_test update body' },
                            :images => { 1 => 'true', 2 => 'true' },
                            :cancel => 'true'
    assert_response :success
    assert_template 'edit_mobile'
    
    dia_entry = DiaEntry.find(:first, :conditions => [" title = 'dia_etnry_controller_test update title' "])
    assert_nil dia_entry # 登録されていない
  end
  
  define_method('test: アルバムリストを表示する') do 
    login_as :quentin
    
    post :album_list
    assert_response :success
    assert_template 'album_list_mobile'
  end
  
  define_method('test: 個別アルバムを表示する') do 
    login_as :quentin
    
    post :album_show, :id => 1
    assert_response :success
    assert_template 'album_show_mobile'
  end
  
  define_method('test: 個別アルバムを表示しようとするが、自分のアルバムではないので表示できない') do 
    login_as :aaron
    
    post :album_show, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 日記に画像を追加する') do 
    login_as :quentin
    
    post :add_images, :type => 'new', :entry => 1, :images => { 1 => 'true', 2 => 'true' } # パラメータは戻る場所を示す
    assert_response :redirect 
    assert_redirected_to :action => 'new'
  end
  
  define_method('test: 日記に画像を追加しようとするが、画像が選択されてないのでflashで警告する') do 
    login_as :quentin
    
    post :add_images, :type => 'new', :entry => 1, :album_id => 1
    assert_response :redirect  
    assert_redirected_to :action => 'album_show', :id => 1, :entry => 1, :type => 'new'
    assert_not_nil flash[:error]
  end
  
  define_method('test: 日記記事を表示する') do 
    login_as :quentin
    
    post :show, :id => 1
    assert_response :success
    assert_template 'show_mobile'
  end
  
  define_method('test: 日記記事を表示しようとするが閲覧権限がないのでエラー画面へ遷移する') do 
    login_as :three
    
    post :show, :id => 8
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 日記記事の個別画像を表示する') do 
    login_as :quentin
    
    post :show_image, :id => 1, :image => 2
    assert_response :success
    assert_template 'show_image_mobile'
  end
  
  define_method('test: 日記記事の個別画像を表示しようとするが記事IDと画像IDに関連がないのでエラー画面へ遷移する') do 
    login_as :quentin
    
    post :show_image, :id => 1, :image => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 日記記事の個別画像を表示しようとするが権限がないのでエラー画面へ遷移する') do 
    login_as :three
    
    post :show_image, :id => 8, :image => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 日記記事を削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm_mobile'
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
    assert_redirected_to :action => 'delete_done'
    
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
    
    post :delete, :id => 1, :cancel => 'true', :cancel_to => "/dia_entry/show/1"
    assert_response :redirect 
    assert_redirected_to :action => 'show', :id => 1
  end
  
  define_method('test: 下書きの日記記事の削除を実行') do 
    login_as :quentin
    
    post :delete_draft, :id => 5 # id = 5 は下書きの記事
    assert_response :redirect 
    assert_redirected_to :action => 'draft_delete_done'
    
    dia_entry = DiaEntry.find_by_id(5)
    assert_nil dia_entry # 削除されている
  end
  
  define_method('test: 下書きの日記記事の削除を実行をキャンセル') do 
    login_as :quentin
    
    post :delete_draft, :id => 5, :cancel => 'true' # id = 5 は下書きの記事
    assert_response :redirect 
    assert_redirected_to :action => 'edit' # 戻るのは編集ページ
    
    dia_entry = DiaEntry.find_by_id(5)
    assert_not_nil dia_entry # 削除されていない
  end
end
