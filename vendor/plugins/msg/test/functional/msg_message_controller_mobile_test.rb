require File.dirname(__FILE__) + '/../test_helper'

module MsgMessageControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
        
        use_transactional_fixtures = false
      end
    end
  end
  
  # メッセージトップページのテスト
  # メッセージ履歴をもつユーザがアクセスしてエラーにならないか
  def test_index
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index_mobile'
  end
  
  # メッセージトップページのテスト
  # メッセージ履歴をもたないユーザがアクセスしてエラーにならないか
  def test_index_non_message
    login_as :ten
    
    post :index
    assert_response :success
    assert_template 'index_mobile'
  end
  
  # 下書き一覧ページのテスト
  # メッセージ履歴をもつユーザがアクセスしてエラーにならないか
  def test_draft_list
    login_as :quentin
    
    post :draft_list
    assert_response :success
    assert_template 'draft_list_mobile'
    
    # ページめくり
    post :draft_list, :page => 10
    assert_response :success
    assert_template 'draft_list_mobile'
  end
  
  # 下書き一覧ページのテスト
  # メッセージ履歴をもつユーザがアクセスしてエラーにならないか
  def test_draft_list_non_message
    login_as :ten
    
    post :draft_list
    assert_response :success
    assert_template 'draft_list_mobile'
    
    # ページめくり
    post :draft_list, :page => 10
    assert_response :success
    assert_template 'draft_list_mobile'
  end
  
  # ゴミ箱一覧ページのテスト
  # メッセージ履歴をもつユーザがアクセスしてエラーにならないか
  def test_garbage_list
    login_as :quentin
    
    post :garbage_list
    assert_response :success
    assert_template 'garbage_list_mobile'
    
    # ページめくり
    post :garbage_list, :page => 10
    assert_response :success
    assert_template 'garbage_list_mobile'
  end
  
  # ゴミ箱一覧ページのテスト
  # メッセージ履歴をもつユーザがアクセスしてエラーにならないか
  def test_garbage_list_non_message
    login_as :ten
    
    post :garbage_list
    assert_response :success
    assert_template 'garbage_list_mobile'
    
    # ページめくり
    post :garbage_list, :page => 10
    assert_response :success
    assert_template 'garbage_list_mobile'
  end
  
  define_method('test: メッセージの新規作成画面を表示する') do 
    login_as :quentin

    post :new
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 宛先を指定してメッセージの新規作成画面を表示する') do 
    login_as :quentin

    # base_user_id = 2 のユーザへメッセージを新規作成, 2はだれからでも受け付ける
    post :new, :receivers => ["2"]
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 宛先を指定してメッセージの新規作成画面を表示しようとするが、友達しか受け付けないユーザのためエラー画面へ遷移する') do 
    login_as :quentin

    # base_user_id = 10 のユーザへメッセージを新規作成, 10は友達からしか受け付けない
    post :new, :receivers => ["10"]
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 宛先を指定してメッセージの新規作成画面を表示しようとするが、友達の友達までしか受け付けないユーザのためエラー画面へ遷移する') do 
    login_as :quentin

    # base_user_id = 3 のユーザへメッセージを新規作成, 3は友達の友達までからしか受け付けない
    # 3 は友達承認待ち状態
    post :new, :receivers => ["3"]
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: メッセージの新規作成画面を表示しようとするが自分自身へメッセージを送ることはできない') do 
    login_as :quentin

    # 自分自身へおくるのはできない
    post :new, :receivers => ["1"]
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  # 新規作成のテスト Friendが絡む系
  def test_new_friend
    login_as :three
    # 3　から　base_user_id = 4 のユーザへメッセージを新規作成, 4は友達
    post :new, :id => 4
    assert_response :success
    assert_template 'new_mobile'
  end
  
  # 新規作成のテスト FoFが絡む系
  def test_new_fof
    login_as :aaron
    # 2　から　base_user_id = 3 のユーザへメッセージを新規作成, 3は2が友達な4の友達
    post :new, :id => 3
    assert_response :success
    assert_template 'new_mobile'
  end
  
  define_method('test: メッセージの宛先一覧選択画面を表示する') do 
    login_as :quentin

    post :friend_list
    assert_response :success
    assert_template 'friend_list_mobile'
    
    assert_not_nil(assigns["receivers"])
    assert_equal(assigns["receivers"].size, 0)
    assert_equal(assigns["base_friends"].size, 1)
  end
  
  define_method('test: メッセージの宛先一覧選択画面を既に追加しているユーザ情報を引き回して表示する') do 
    login_as :quentin

    post :friend_list, :receivers => ["2"]
    assert_response :success
    assert_template 'friend_list_mobile'
    
    assert_not_nil(assigns["receivers"])
    assert_equal(assigns["base_friends"].size, 0) # base_user_id = 2は灯籠済みなので表示できるユーザがいない
  end
  
  define_method('test: メッセージの作成確認画面を表示をする') do 
    login_as :quentin

    # 正常投稿
    post :confirm, :message => {:title => 'test title', :body => 'test body'}, :receivers => ["2"]
    assert_response :success
    assert_template 'confirm_mobile'
  end
  
  define_method('test: メッセージの作成確認画面を表示しようとするが、タイトルがないので作成ページへ戻る') do 
    login_as :quentin

    # 正常投稿
    post :confirm, :message => {:body => 'test body'}, :receivers => ["2"]
    assert_response :success
    assert_template 'new_mobile' # 新規作成ページを表示
  end
  
  define_method('test: メッセージの作成確認画面を表示しようとするが、本文がないので作成ページへ戻る') do 
    login_as :quentin

    # 正常投稿
    post :confirm, :message => {:title => 'test title'}, :receivers => ["2"]
    assert_response :success
    assert_template 'new_mobile' # 新規作成ページを表示
  end
  
  define_method('test: 下書きメッセージを新規作成実行をする') do 
    login_as :ten
    
    # 下書き投稿:下書きは完了画面がないのでその場で保存される
    post :confirm, :draft => 'true', :message => {:title => 'test draft confirm title', :body => 'test body'}, :receivers => ["1"]
    assert_response :redirect
    
    msg_message = MsgMessage.find(:first, :conditions => [" title = 'test draft confirm title'"])
    assert_redirected_to :action => 'draft_done', :id => msg_message.id
    
    # 送信者のレコード確認
    msg_sender = MsgSender.find(:first, :conditions => [' base_user_id = ? ', 10], :order => 'created_at desc')
    assert_not_nil msg_sender
    assert_equal msg_sender.draft_flag, true
    
    # 受信者のレコード確認
    msg_receiver = MsgReceiver.find(:first, :conditions => [' base_user_id = ? ', 1], :order => 'created_at desc')
    assert_not_nil msg_receiver
    assert_equal msg_receiver.draft_flag, true
  end
  
  define_method('test: メッセージの新規作成実行をする') do 
    login_as :ten
    
    # 新規作成実行
    post :create, :message => {:title => 'test create title', :body => 'test body'}, :receivers => ["1"]
    assert_response :redirect
    
    msg_message = MsgMessage.find(:first, :conditions => [" title = 'test create title'"])
    assert_redirected_to :action => 'done', :id => msg_message.id
    
    assert_not_nil msg_message
    assert_equal msg_message.title, 'test create title'
    assert_equal msg_message.body, 'test body'
    
    # 送信者のレコード確認
    assert_not_nil msg_message.msg_sender
    assert_equal(msg_message.msg_sender.base_user_id, 10)
    assert_equal(msg_message.msg_sender.draft_flag, false)
    
    # 受信者のレコード確認
    assert_not_nil msg_message.msg_receivers
    assert_equal(msg_message.msg_receivers.size, 1)
    assert_equal(msg_message.msg_receivers[0].base_user_id, 1)
    assert_equal(msg_message.msg_receivers[0].read_flag, false)
  end
  
  define_method('test: create はキャンセルボタンを押されたらメッセージの新規作成をせずに編集画面へ戻る') do 
    login_as :ten
    
    # 新規作成実行
    post :create, :message => {:title => 'test create title', :body => 'test body'}, :receivers => ["1"],
                  :cancel => 'true'
    assert_response :success
    assert_template 'new_mobile'    
    
    msg_message = MsgMessage.find(:first, :conditions => [" title = 'test create title'"])
    
    assert_nil msg_message # 作成されていない
  end
  
  define_method('test: メッセージの新規作成実行完了画面を表示をする') do 
    login_as :ten
    
    post :done, :id => 1
    assert_response :success
    assert_template 'done_mobile'
    
    assert_not_nil(assigns["msg_message"])
  end
  
  # 編集画面のテスト
  def test_edit
    login_as :quentin

    # 編集可能なユーザ
    post :edit, :id => 1
    assert_response :success
    assert_template 'edit_mobile'
    
    # 受信(する予定のユーザ)が退会している場合エラーになる
    post :edit, :id => 12
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  # 編集できないユーザが排除されているかのテスト
  def test_edit_not_edit
    login_as :ten

    # 編集不可能なユーザ
    post :edit, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  # メッセージ更新のテスト
  def test_update_confirm
    login_as :quentin

    # 正常更新
    post :update_confirm, :id => 1, :message => {:title => 'update tset title', :body => 'update test body'}
    assert_response :success
    assert_template 'update_confirm_mobile'
    
    # タイトルがない
    post :update_confirm, :id => 1, :message => {:body => 'update test body'}
    assert_response :success
    assert_template 'edit_mobile' # 編集画面に戻る
    
    # 本文がない
    post :update_confirm, :id => 1, :message => {:title => 'update tset title'}
    assert_response :success
    assert_template 'edit_mobile' # 編集画面に戻る
  end

  # 編集できないユーザが排除されているかのテスト
  def test_update_confirm_not_edit
    login_as :ten

    # 編集可能なユーザ
    post :update_confirm, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  # 更新の際も下書きのままにする確認画面のテスト
  def test_update_confirm_draft
    login_as :quentin
    
    # 下書き投稿:下書きは完了画面がないのでその場で保存される
    post :update_confirm, :id => 1, :draft => 'true', :message => {:title => 'update test title', :body => 'update test body'}
    assert_response :redirect
    assert_redirected_to :action => 'draft_done'
  end 
  
  define_method('test: メッセージの更新をする') do
    login_as :quentin
    
    post :update, :id => 2, :message => {:title => 'update test title', :body => 'update test body'}, :receivers => ["2"] 
    assert_response :redirect
    assert_redirected_to :action => 'done'
  
    msg_message = MsgMessage.find(2)
    assert_not_nil msg_message
    assert_equal msg_message.title, 'update test title'
    assert_equal msg_message.body, 'update test body'
  end
  
  #　下書き削除のテスト
  def test_delete_draft_messages_confirm
    login_as :quentin
    
    # idが2と3の記事を消す: hashのkeyを利用しているのでvalueは無視　TODO:これってへんくない？
    post :delete_draft_messages_confirm, :del => { 2 => nil, 3 => nil }
    assert_response :success
    assert_template 'delete_draft_messages_confirm_mobile'
    
  end
  
  define_method('test: 下書きを削除しようとするが削除するものを選択していなければ下書き一覧に戻る') do
    login_as :quentin
    
    post :delete_draft_messages_confirm
    assert_response :redirect
    assert_redirected_to :action =>  'draft_list'
  end
  
  
  # 作成者じゃないユーザが下書きを消そうとしたらエラーになるテスト
  def test_delete_draft_messages_confirm_non_sender_user
    login_as :aaron
    
    # idが1の記事を消すが作成者じゃないのでエラーになる
    post :delete_draft_messages_confirm, :del => { 2 => nil }
    assert_response :redirect
    assert_redirected_to :action => 'error' # 作成者以外が消そうとするとエラー
  end
  
  # 下書き削除実行
  def test_delete_draft_messages
    login_as :quentin
    
    # idが2と3の記事を消す
    post :delete_draft_messages, :del => { 2 => nil, 3 => nil }
    assert_response :redirect
    assert_redirected_to :action => 'delete_draft_done'
    
    # 削除されている
    msg_message = MsgMessage.find_with_deleted(2)
    assert_not_nil msg_message.deleted_at # 削除日付が入っている
    
    msg_message2 = MsgMessage.find_with_deleted(3)
    assert_not_nil msg_message2.deleted_at
  end
  
  # 下書き削除実行するがユーザが送信者じゃないので拒否される
  def test_delete_draft_messages_non_sender_user
    login_as :aaron
    
    # idが2の記事を消すが作成者じゃないのでエラーになる
    post :delete_draft_messages, :del => { 2 => nil }
    assert_response :redirect
    assert_redirected_to :action => 'error' # 作成者以外が消そうとするとエラー
  end
  
  # リプライのテスト
  def test_reply
    login_as :quentin
    
    # msg_messge_id = 1のメッセージに返信
    post :reply, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error' # msg_message_id = 1の作成者はquestinなのでreplyできない
    
    # msg_messge_id = 11のメッセージに返信
    post :reply, :id => 11
    assert_response :redirect
    assert_redirected_to :action => 'error' # 送信ユーザーが退会しているのでreplyできない
    
    # msg_messge_id = 5のメッセージに返信
    post :reply, :id => 5
    assert_response :success
    assert_template 'new_mobile'
  end
  
  # リプライ時に引用する場合のテスト
  def test_reply_with_quotation
    login_as :quentin
    
    # msg_messge_id = 1のメッセージに返信
    post :reply_with_quotation, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error' # msg_message_id = 1の作成者はquestinなのでreplyできない
    
    # msg_messge_id = 11のメッセージに返信
    post :reply, :id => 11
    assert_response :redirect
    assert_redirected_to :action => 'error' # 送信ユーザーが退会しているのでreplyできない
    
    # msg_messge_id = 5のメッセージに返信
    post :reply_with_quotation, :id => 5
    assert_response :success
    assert_template 'new_mobile'
  end
  
  # ゴミ箱の中身のメッセージを見る
  def test_garbage_show
    login_as :quentin
    
    post :garbage_show, :id => 1 # TODO 状態みてないみたいだけど問題ないのかな？
    assert_response :success
    assert_template 'garbage_show_mobile'
  end
  
  # ゴミ箱を空にする確認画面
  def test_clean_trash_box_confirm
    login_as :quentin
    
    post :clean_trash_box_confirm
    assert_response :success
    assert_template 'clean_trash_box_confirm_mobile'
  end
  
  # ゴミ箱を空にする
  def test_clean_trash_box
    login_as :quentin
    
    post :clean_trash_box
    assert_response :redirect
    assert_redirected_to :action => 'clean_trash_box_done'
  end
  
end
