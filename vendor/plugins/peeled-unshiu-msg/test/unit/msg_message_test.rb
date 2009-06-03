require File.dirname(__FILE__) + '/../test_helper'

module MsgMessageTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :msg_messages
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :msg_notifies
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_friends
      end
    end
  end
  
  define_method('test: MsgMessageのテーブル関連') do 
    # FIXME fixturesのデータ量に応じて結果がかわるのでよくない
    msg_message = MsgMessage.find(1)
    assert_not_nil msg_message.msg_sender
    assert_not_nil msg_message.msg_receivers
    assert_not_nil msg_message.parent_message
    assert_equal 2, msg_message.parent_message.id
    assert_not_nil msg_message.child_messages
    assert_equal 3, msg_message.child_messages.size
    assert_equal 3, msg_message.child_messages[0].id
    assert_equal 4, msg_message.child_messages[1].id
    assert_not_nil msg_message.msg_notifies
  end
  
  define_method('test: メッセージの受信者のユーザ情報を取得する') do 
    msg_message = MsgMessage.find(1)
    
    assert_not_nil(msg_message.msg_receivers) # 受信情報
    assert_not_nil(msg_message.msg_receiver_base_users) # 受信者情報
    
    msg_message.msg_receiver_base_users.each do |msg_receiver|
      assert_instance_of(BaseUser, msg_receiver.base_user)
    end
  end
  
  # メッセージ送信可能チェックのテスト
  def test_acceptable?
    # 「サービス利用者全員」 に許可しているユーザー
    receiver_id = 1
    
    # 自分
    sender = BaseUser.find(1)
    assert_equal false, MsgMessage.acceptable?(sender, receiver_id)
    # 友だち
    sender = BaseUser.find(2)
    assert MsgMessage.acceptable?(sender, receiver_id)
    # 友だちの友だち
    sender = BaseUser.find(4)
    assert MsgMessage.acceptable?(sender, receiver_id)
    # ログインユーザー
    sender = BaseUser.find(3)
    assert MsgMessage.acceptable?(sender, receiver_id)

    # 「友だちの友だちまで」 に許可しているユーザー
    receiver_id = 2
    
    # 自分
    sender = BaseUser.find(2)
    assert_equal false, MsgMessage.acceptable?(sender, receiver_id)
    # 友だち
    sender = BaseUser.find(1)
    assert MsgMessage.acceptable?(sender, receiver_id)
    # 友だちの友だち
    sender = BaseUser.find(5)
    assert MsgMessage.acceptable?(sender, receiver_id)
    # ログインユーザー
    sender = BaseUser.find(10)
    assert !MsgMessage.acceptable?(sender, receiver_id)
    
    # 「友だちのみ」 に許可しているユーザー
    receiver_id = 4
    
    # 自分
    sender = BaseUser.find(4)
    assert !MsgMessage.acceptable?(sender, receiver_id)
    # 友だち
    sender = BaseUser.find(2)
    assert MsgMessage.acceptable?(sender, receiver_id)
    # 友だちの友だち
    sender = BaseUser.find(1)
    assert !MsgMessage.acceptable?(sender, receiver_id)
    # ログインユーザー
    sender = BaseUser.find(10)
    assert !MsgMessage.acceptable?(sender, receiver_id)
    
    # 非ログインユーザー
    assert !MsgMessage.acceptable?(nil, receiver_id)
  end

  # ゴミ箱メッセージの数を取得するテスト
  def test_garbage_count
    assert_equal 2, MsgMessage.garbage_count(1)
  end
  
  define_method('test: garbage_messages_with_paginate はゴミ箱メッセージ一覧をpaginate付きで取得する') do 
    messages = MsgMessage.garbage_messages_with_paginate(1, 10, nil) # 1ページめ
    
    assert_not_nil(messages)
    messages.load_page
    assert_equal 2, messages.results.size
  end
  
  define_method('test: garbage はゴミ箱メッセージ一覧をすべて取得する') do 
    messages = MsgMessage.garbage(1) 
    
    assert_not_nil(messages)
    assert(messages.size > 0)
    messages.each do |message| # ゴミ箱にはいっていればOK
      trash_flag = false
      if message.msg_sender.base_user_id == 1
        trash_flag = true if message.msg_sender.trash_status == MsgMessage::TRASH_STATUS_GARBAGE
      else
        message.msg_receivers.each do |reciver|
          if reciver.trash_status == MsgMessage::TRASH_STATUS_GARBAGE && reciver.base_user_id == 1
             trash_flag = true
          end 
        end
      end
      assert(trash_flag)
    end
  end
  
  define_method('test: next_message であるゴミ箱のメッセージの次のメッセージを取得する') do 
    message = MsgMessage.garbage(1).next_message(1).first
    
    assert_not_nil(message)
    assert(message.id > 1) # idは1以上
    
    trash_flag = false # ゴミ箱にはいっている
    if message.msg_sender.base_user_id == 1
      trash_flag = true if message.msg_sender.trash_status == MsgMessage::TRASH_STATUS_GARBAGE
    else
      message.msg_receivers.each do |reciver|
        if reciver.trash_status == MsgMessage::TRASH_STATUS_GARBAGE && reciver.base_user_id == 1
           trash_flag = true
        end 
      end
    end
    assert(trash_flag)
  end
  
  define_method('test: prev_message であるゴミ箱のメッセージの前のメッセージを取得する') do 
    message = MsgMessage.garbage(1).prev_message(999).first
    
    assert_not_nil(message)
    assert(message.id < 999) # idは999以下
    
    trash_flag = false # ゴミ箱にはいっている
    if message.msg_sender.base_user_id == 1
      trash_flag = true if message.msg_sender.trash_status == MsgMessage::TRASH_STATUS_GARBAGE
    else
      message.msg_receivers.each do |reciver|
        if reciver.trash_status == MsgMessage::TRASH_STATUS_GARBAGE && reciver.base_user_id == 1
           trash_flag = true
        end 
      end
    end
    assert(trash_flag)
  end
  
  # ゴミ箱を空にするテスト
  def test_clean_trash_box
    # 空でないことを確認
    assert_equal 2, MsgMessage.garbage_count(1)
    
    # 空にする
    MsgMessage.clean_trash_box(1)
    
    # 空になったことを確認
    assert_equal 0, MsgMessage.garbage_count(1)
  end
  
  # 下書きでないメッセージ一覧を取得するテスト
  def test_undraft_messages
    assert_not_nil messages = MsgMessage.undraft_messages(nil) # 1ページめ
    messages.load_page
    assert_equal 9, messages.results.size
  end
  
  # 管理者送信メッセージ一覧を取得するテスト
  def test_manager_messages
    assert_not_nil messages = MsgMessage.manager_messages(nil) # 1ページめ
    messages.load_page
    assert_equal 11, messages.results.size
  end
  
  # 通報されたメッセージ一覧を取得するテスト
  def test_notified_messages
    assert_not_nil messages = MsgMessage.notified_messages(nil) # 1ページめ
    messages.load_page
    assert_equal 2, messages.results.size
  end
  
  # 送信者チェックのテスト
  def test_sender?
    # 対象ユーザーの取得
    base_user = BaseUser.find(1)
    
    message = MsgMessage.find(1) # 送信者なメッセージ
    assert message.sender?(base_user)
    
    message = MsgMessage.find(5) # 送信者でないメッセージ
    assert !message.sender?(base_user)
    
    # 非ログイン
    assert !message.sender?(:false)
   end

  # 受信者チェックのテスト
  def test_receiver?
    # 対象ユーザーの取得
    base_user = BaseUser.find(1)

    message = MsgMessage.find(5) # 受信者なユーザー
    assert message.receiver?(base_user)
    
    message = MsgMessage.find(1) # 受信者でないユーザー
    assert !message.receiver?(base_user)
    
    # 非ログイン
    assert !message.receiver?(:false)
  end
  
  # MsgReceiver オブジェクト取得のテスト
  def test_msg_receiver
    # 対象メッセージ取得
    message = MsgMessage.find(1)
    
    assert_not_nil message.msg_receiver(2) # 受信者でないユーザー
    assert_nil message.msg_receiver(1) # 受信者なユーザー
    assert_nil message.msg_receiver(3) # 受信者でないユーザー
  end
  
  define_method('test: リプライ用タイトルを設定する') do 
    message = MsgMessage.new
    message.reply_title = "unshiu"
    
    assert_equal(message.title, "Re: unshiu")
  end
  
  define_method('test: リプライ用タイトルに最大文字数以上設定されたら自動で語尾を削る') do 
    message = MsgMessage.new
    message.reply_title = "あ" * 100
    
    assert_equal(message.title, "Re: "+ ("あ" * (100 - 4))) # Re: 分の文字数を引いている
    
    message = MsgMessage.new
    message.reply_title = "A" * 100
    
    assert_equal(message.title, "Re: "+ ("A" * (100 - 4))) # Re: 分の文字数を引いている
  end
  
  define_method('test: リプライ用に本文を設定する') do 
    message = MsgMessage.new
    message.reply_body = "unshiu\nunshiu\n"
    
    assert_equal(message.body, "> unshiu\n> unshiu\n")
  end
  
  define_method('test: リプライ用に本文最大文字数以上設定されたら自動で語尾を削る') do 
    message = MsgMessage.new
    message.reply_body = "あ" * 5000
    
    assert_equal(message.body, "> "+ ("あ" * (5000 - 2))) # > 分の文字数を引いている
    
    message = MsgMessage.new
    message.reply_body = "A" * 5000
    
    assert_equal(message.body, "> "+ ("A" * (5000 - 2))) # > 分の文字数を引いている
  end
  
end
