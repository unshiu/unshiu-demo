require File.dirname(__FILE__) + '/../test_helper'

module MsgMessageControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_profiles
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
        
        use_transactional_fixtures = false
        
      end
    end
  end
  
  define_method('test: メッセージトップページを表示する') do 
    login_as :quentin
    
    get :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns["msg_messages"])
  end
  
  define_method('test: メッセージ新規作成ページを表示する') do 
    login_as :quentin
    
    post :new, :receivers => ["2"] # base_user_id = 2 のユーザへメッセージを新規作成, 2はだれからでも受け付ける
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 送信者を特定しないでメッセージ新規作成ページを表示する') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new'
    
    assert_not_nil(assigns["received_count"])
    assert_not_nil(assigns["sent_count"])
    assert_not_nil(assigns["draft_count"])
    assert_not_nil(assigns["garbage_count"])
  end
  
  define_method('test: メッセージ新規作成ページを表示しようとするが、自分自身へのメッセージなのでエラーを表示する') do 
    login_as :quentin
    
    post :new, :receivers => ["1"]
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: メッセージ新規作成ページを表示しようとするが、友達しかメッセージを受け付けていない人なのでエラーを表示する') do 
    login_as :quentin
    
    post :new, :receivers => ["10"] # base_user_id = 10 のユーザへメッセージを新規作成, 10は友達からしか受け付けない
    assert_response :redirect
    assert_redirected_to :action => 'error' 
  end
  
  define_method('test: メッセージ新規作成ページを表示しようとするが、友達の友達までしかメッセージを受け付けていない人なのでエラーを表示する') do 
    login_as :quentin
    
    post :new, :receivers => ["3"] # base_user_id = 3 のユーザへメッセージを新規作成, 3は友達の友達までからしか受け付けない
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end

  define_method('test: receivers は友達一覧JSONを取得する') do 
    login_as :quentin
    
    get :receivers_remote
    assert_response :success
    
    answer_body = [{:id => 2, :text => nil, :image => "/images/default/icon/default_profile_image.gif", :extra => nil}]
    assert_equal(@response.body, answer_body.to_json)
  end
  
  define_method('test: receiver は指定ユーザを送信者として追加する') do 
    login_as :quentin
    
    post :receiver, :receiver => {:id => 1, :text => "texttext", :image => "image", :extra => "extra"}
    assert_response :success
    
    assert_equal(assigns["receiver"]["id"], "1")
    assert_equal(assigns["receiver"]["image"], "image")
    assert_equal(assigns["receiver"]["text"], "texttext")
    assert_equal(assigns["receiver"]["extra"], "extra")
  end
  
  define_method('test: メッセージに返信する') do 
    login_as :quentin
    
    get :reply, :id => 5
    assert_response :success
    assert_template 'new'
    
    assert_not_nil(assigns["message"])
  end
  
  define_method('test: メッセージに返信しようとするが、自分が作成したメッセージでないので返信できない') do 
    login_as :quentin
    
    post :reply, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error' # msg_message_id = 1の作成者はquestinなのでreplyできない
  end
  
  define_method('test: メッセージに返信しようとするが、送信ユーザーが退会しているので返信できない') do 
    login_as :quentin
    
    post :reply, :id => 11
    assert_response :redirect
    assert_redirected_to :action => 'error' # 送信ユーザーが退会しているのでreplyできない
  end
  
  define_method('test: メッセージ送信実行処理をする') do 
    login_as :ten
    
    # base_user_id = 1 宛に新規作成実行
    post :create, :message => {:title => 'test title', :body => 'test body'}, :receivers => ["1"]
    assert_response :redirect
    assert_redirected_to :action => 'index'

    msg_message = MsgMessage.find(:first, :conditions => [" title = 'test title'"])
    assert_not_nil msg_message
    assert_equal msg_message.title, 'test title'
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
  
  define_method('test: 複数宛にメッセージ送信実行処理をする') do 
    login_as :four
    
    # base_user_id = 2 と 5 宛に新規作成実行
    post :create, :message => {:title => 'test title', :body => 'test body'}, :receivers => ["2", "5"]
    assert_response :redirect
    assert_redirected_to :action => 'index'

    msg_message = MsgMessage.find(:first, :conditions => [" title = 'test title'"])
    assert_not_nil msg_message
    assert_equal msg_message.title, 'test title'
    assert_equal msg_message.body, 'test body'
    
    # 送信者のレコード確認
    assert_not_nil msg_message.msg_sender
    assert_equal(msg_message.msg_sender.base_user_id, 4)
    assert_equal(msg_message.msg_sender.draft_flag, false)
    
    # 受信者のレコード確認
    assert_not_nil msg_message.msg_receivers
    assert_equal(msg_message.msg_receivers.size, 2)
    assert_equal(msg_message.msg_receivers[0].base_user_id, 2)
    assert_equal(msg_message.msg_receivers[0].read_flag, false)
    assert_equal(msg_message.msg_receivers[1].base_user_id, 5)
    assert_equal(msg_message.msg_receivers[1].read_flag, false)
  end
  
  define_method('test: create はメッセージを送信実行処理をしようとするがタイトルがないため入力画面へ戻る') do 
    login_as :ten
    
    assert_difference 'MsgMessage.count', 0 do
      post :create, :message => {:title => '', :body => 'test body'}, :receivers => ["1"]
      assert_response :success
      assert_template 'new'
    end
  end
  
  define_method('test: create はメッセージを送信実行処理をしようとするが送信先が指定されていないため入力画面へ戻る') do 
    login_as :ten
    
    assert_difference 'MsgMessage.count', 0 do
      post :create, :message => {:title => 'test title', :body => 'test body'}
      assert_response :success
      assert_template 'new'
    end
  end
  
  define_method('test: create は送信ユーザが指定されていないとメッセージの送信実行はせず入力画面へ戻る') do 
    login_as :ten
    
    assert_difference 'MsgMessage.count', 0 do
      post :create, :message => {:title => 'test', :body => 'test body'}
      assert_response :success
      assert_template 'new'
    end
  end
  
  define_method('test: メッセージを下書き保存する') do 
    login_as :four
    
    # 下書き投稿:下書きは完了画面がないのでその場で保存される
    post :create, :draft => 'true', :message => {:title => 'test title', :body => 'test body'}, :receivers => ["2", "5"]
    assert_response :redirect
    assert_redirected_to :action => 'index'
    
    # 送信者のレコード確認
    msg_sender = MsgSender.find(:first, :conditions => [' base_user_id = ? ', 4], :order => 'created_at desc')
    assert_not_nil msg_sender
    assert_equal msg_sender.draft_flag, true
    
    # 受信者のレコード確認
    msg_receivers = msg_sender.msg_message.msg_receivers
    assert_equal(msg_receivers.size, 2)
    assert_equal(msg_receivers[0].base_user_id, 2)
    assert_equal(msg_receivers[1].base_user_id, 5)
    
    msg_receivers.each do |msg_receiver|
      assert_equal(msg_receiver.draft_flag, true)
    end
    
  end
  
  define_method('test: 編集画面を表示する') do 
    login_as :quentin
    
    post :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    
    assert_not_nil(assigns["received_count"])
    assert_not_nil(assigns["sent_count"])
    assert_not_nil(assigns["draft_count"])
    assert_not_nil(assigns["garbage_count"])
  end
  
  define_method('test: 編集画面を表示しようとするが、作成者でない場合はエラー画面へ遷移') do 
    login_as :ten
    
    post :edit, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: 編集画面を表示しようとするが、作成者でない場合はエラー画面へ遷移') do 
    login_as :ten
    
    post :edit, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end

  define_method('test: update はメッセージの更新し送信処理をする') do
    login_as :quentin
    
    post :update, :id => 2, :message => {:title => 'update test title', :body => 'update test body'}, :receivers => ["2"] 
    assert_response :redirect
    assert_redirected_to :controller => 'msg_message', :action => 'draft_list'
  
    msg_message = MsgMessage.find(2)
    assert_not_nil msg_message
    assert_equal msg_message.title, 'update test title'
    assert_equal msg_message.body, 'update test body'
  end
  
  define_method('test: update はメッセージの下書き更新をする') do
    login_as :quentin
    
    post :update, :id => 4, :message => {:title => 'update test title', :body => 'update test body'}, 
                            :receivers => ["2"], :draft => "true" 
    assert_response :redirect
    assert_redirected_to :controller => 'msg_message', :action => 'draft_list'
  
    msg_message = MsgMessage.find(4)
    assert_not_nil msg_message
    assert_equal msg_message.title, 'update test title'
    assert_equal msg_message.body, 'update test body'
    assert_equal(msg_message.msg_sender.draft_flag, true)
  end
  
  define_method('test: 下書きメッセージ一覧を表示する') do 
    login_as :quentin
    
    post :draft_list
    assert_response :success
    assert_template 'draft_list'
  end
  
  define_method('test: delete_draft_messages_confirm は下書きメッセージ削除の確認画面を表示する') do 
    login_as :quentin
    
    # idが2と3の記事を消す: hashのkeyを利用しているのでvalueは無視
    # 実際に使われるのはmessage_idの方
    post :delete_draft_messages_confirm, :del => { 2 => nil, 3 => nil }, :message_ids => { 2 => nil, 3 => nil}
    assert_response :success
    assert_template 'delete_draft_messages_confirm'
    
  end
  
  define_method('test: delete_draft_messages_confirm は削除するものを選択していなければ下書き一覧に戻る') do
    login_as :quentin
    
    post :delete_draft_messages_confirm
    assert_response :redirect
    assert_redirected_to :action =>  'draft_list'
  end
  
  define_method('test: delete_draft_messages_confirm は作成者じゃないユーザが下書きを消そうとしたらエラー画面へ遷移する') do
    login_as :aaron
    
    # idが1の記事を消すが作成者じゃないのでエラーになる
    post :delete_draft_messages_confirm, :del => { 2 => nil }, :message_ids => { 2 => nil }
    assert_response :redirect
    assert_redirected_to :action => 'error' 
  end
  
  define_method('test: delete_draft_messages は下書き削除を実行する') do
    login_as :quentin
    
    # idが2と3の記事を消す
    post :delete_draft_messages, :del => { 2 => nil, 3 => nil }
    assert_response :redirect
    assert_redirected_to :action => 'draft_list'
    
    # 削除されている
    msg_message = MsgMessage.find_with_deleted(2)
    assert_not_nil msg_message.deleted_at # 削除日付が入っている
    
    msg_message2 = MsgMessage.find_with_deleted(3)
    assert_not_nil msg_message2.deleted_at
  end
  
  define_method('test: delete_draft_messages は送信者ではないユーザが下書き削除を実行しようとするとエラー画面へ遷移する') do
    login_as :aaron
    
    # idが2の記事を消すが作成者じゃないのでエラーになる
    post :delete_draft_messages, :del => { 2 => nil }
    assert_response :redirect
    assert_redirected_to :action => 'error' 
  end
  
  define_method('test: ゴミ箱メッセージ一覧を表示する') do 
    login_as :quentin
    
    post :garbage_list
    assert_response :success
    assert_template 'garbage_list'
  end
  
  define_method('test: ゴミ箱メッセージ一覧はゴミ箱にメッセージがないユーザがアクセスしてもエラーにならない') do 
    login_as :ten
    
    post :garbage_list
    assert_response :success
    assert_template 'garbage_list'
  end
  
  define_method('test: ゴミ箱の中身のメッセージを見る') do 
    login_as :quentin
    
    post :garbage_show, :id => 1 
    assert_response :success
    assert_template 'garbage_show'
    
    assert_not_nil(assigns['next_message'])
    assert_nil(assigns['prev_message']) # 1 より前のものはない
  end
  
  define_method('test: delete_from_trash_box_confirm ゴミ箱からも削除する確認画面を表示する') do 
    login_as :quentin
    
    post :delete_from_trash_box_confirm, :del => {1 => {"sender" => true}, 2 => {"sender" => true}, 5 => {"receiver" => true}}
    assert_response :success 
    assert_template 'delete_from_trash_box_confirm'
  end
  
  define_method('test: delete_from_trash_box_confirm は適切ではないメッセージをゴミ箱からも削除しようとするとエラー画面へ遷移する') do 
    login_as :quentin
    
    post :delete_from_trash_box_confirm, :del => {1 => {"'receiver'" => true}, 5 => {"'sender'" => true}}
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: delete_from_trash_box_confirm は削除するメッセージが指定されなければゴミ箱を表示') do 
    login_as :quentin
    
    post :delete_from_trash_box_confirm
    assert_response :redirect
    assert_redirected_to :action => 'garbage_list'
  end
  
  define_method('test: delete_from_trash_box ゴミ箱からも完全に削除する') do 
    login_as :quentin
    
    post :delete_from_trash_box, :del => {1 => {"'sender'" => true}, 2 => {"'sender'" => true}, 5 => {"'receiver'" => true}}
    assert_response :redirect
    assert_redirected_to :controller => "msg_message", :action => 'garbage_list'
    
    msg_sender = MsgSender.find_by_id(1)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_BURN # ステータスが完全削除
    
    msg_sender = MsgSender.find_by_id(2)
    assert_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_BURN 
    
    msg_receiver = MsgReceiver.find(:first, :conditions => ['base_user_id = 1 and msg_message_id = 5'])
    assert_equal msg_receiver.trash_status, MsgMessage::TRASH_STATUS_BURN 
  end
  
  define_method('test: delete_from_trash_box は適切ではないメッセージをゴミ箱からも削除しようとするとエラー画面へ遷移する') do 
    login_as :quentin
    
    post :delete_from_trash_box_confirm, :del => {5 => {"'sender'" => true}}
    assert_response :redirect
    assert_redirected_to :action => 'error'
  end
  
  define_method('test: delete_from_trash_box はキャンセルボタンを押されるとゴミ箱一覧ページに戻る') do 
    login_as :quentin
    
    post :delete_from_trash_box, :del => {1 => {"sender" => true}, 2 => {"sender" => true}}, 
                                 :cancel => "true"
    assert_response :success
    assert_template "garbage_list"
    
    # ステータスに変更はない
    msg_sender = MsgSender.find_by_id(1)
    assert_not_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_BURN 
    
    msg_sender = MsgSender.find_by_id(2)
    assert_not_equal msg_sender.trash_status, MsgMessage::TRASH_STATUS_BURN 
  end
end
