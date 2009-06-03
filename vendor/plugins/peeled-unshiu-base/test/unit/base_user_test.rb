require File.dirname(__FILE__) + '/../test_helper'

module BaseUserTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_friends
        fixtures :base_favorites
        fixtures :msg_senders
        fixtures :msg_receivers
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :cmm_communities_base_users
        fixtures :cmm_communities
        fixtures :abm_albums
        fixtures :abm_image_comments
        fixtures :prf_profiles
        fixtures :prf_answers
        fixtures :pnt_points
        fixtures :base_mail_templates
        fixtures :base_mail_template_kinds
      end
    end
  end
  
  # 関連のテスト
  def test_relation
    base_user = BaseUser.find(1)
    assert_not_nil base_user.base_friends
    assert_not_nil base_user.friends
    assert_not_nil base_user.friend_applies

    assert_not_nil base_user.base_favorites
    assert_not_nil base_user.favorites

    assert_not_nil base_user.base_profile

    assert_not_nil base_user.base_user_roles

    assert_not_nil base_user.dia_diaries
    assert_not_nil base_user.dia_entries
    assert_not_nil base_user.dia_entry_comments
    assert_not_nil base_user.dia_commented_entries

    assert_not_nil base_user.msg_senders
    assert_not_nil base_user.msg_send_messages
    assert_not_nil base_user.msg_draft_messages
    assert_not_nil base_user.msg_receivers
    assert_not_nil base_user.msg_receive_messages
    assert_not_nil base_user.msg_unread_messages

    assert_not_nil base_user.cmm_communities_base_users
    assert_not_nil base_user.cmm_communities

    assert_not_nil base_user.abm_albums
    assert_not_nil base_user.abm_image_comments

    assert_not_nil base_user.prf_profile

    assert_not_nil base_user.pnt_points
  end

  # show_name のテスト
  def test_show_name
    # nil が返ってこなければOK
    current_base_user = BaseUser.find(1)
    assert_not_nil current_base_user.show_name
  end

  #　self版 active? のテスト
  def test_self_active?
    # アクティブなユーザー
    assert BaseUser.active?(1)

    # アクティブでない(アクセス禁止)ユーザー
    assert_equal false, BaseUser.active?(6)

    #　存在しないユーザー
    assert_equal false, BaseUser.active?(777)
  end

  # インスタンス版 active? のテスト
  def test_active?
    # アクティブなユーザー
    base_user = BaseUser.find(1)
    assert base_user.active?

    # アクティブでない(アクセス禁止)ユーザー
    base_user = BaseUser.find(6)
    assert_equal false, base_user.active?
  end

  # forbidden? のテスト
  def test_forbidden?

    # アクセス禁止ユーザー
    base_user = BaseUser.find(6)
    assert base_user.forbidden?

    # アクティブなユーザー
    base_user = BaseUser.find(1)
    assert_equal false, base_user.forbidden?
  end

  define_method('test: 退会済みかどうかを確認する') do
    base_user = BaseUser.find_with_deleted(1)
    assert_equal base_user.withdrawal?, false # 退会済みではない
    
    base_user = BaseUser.find_with_deleted(14)
    assert_equal base_user.withdrawal?, true # 退会済み
  end
  
  # make_activation_code のテスト
  def test_make_activation_code
    # activation_code が変化するかのテスト
    base_user = BaseUser.find(1)
    old_activation_code = base_user.activation_code
    base_user.make_activation_code
    assert_not_equal base_user.activation_code, old_activation_code
  end

  # active_users のテスト
  def test_active_users
    # 人数でチェックしているので base_users.yml でアクティブなユーザーを増やすと failure になるので直してください
    assert_equal 6, BaseUser.active_users.length
  end

  define_method('test: メールアドレスから仮登録ユーザを生成する') do
    base_user = BaseUser.create_temporary_user_from_email("create_temporary_user@unshiu.drecom.jp")
    assert_not_nil(base_user)
    assert_equal(base_user.status, BaseUser::STATUS_TEMPORARY)
  end
  
  define_method('test: メールアドレスから仮登録ユーザを生成しようとするが登録済みのユーザなので新規作成はされない') do
    base_user = BaseUser.create_temporary_user_from_email("mobilesns-dev@devml.drecom.co.jp")
    assert_not_nil(base_user)
    assert_equal(base_user.active?, true) # 有効なユーザ
  end
  
  # temporary_registration のテスト
  # temporary_registration_core のテストも含む
  def test_temporary_registration
    # テスト用に現在の数を取得
    users_count = BaseUser.count
    active_users_count = BaseUser.active_users.size

    # 登録用メールアドレスに空メールが届いたときのテスト
    registration_mail = read_mail_fixture('base_mailer_notifier', 'registration')
    BaseMailerNotifier.receive(registration_mail.to_s)
    assert_not_nil BaseUser.find_by_email("example@example.com")

    # 全ユーザー数は1増えている，アクティブユーザー数は増えていない
    assert_equal users_count + 1, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size
    users_count = BaseUser.count

    # 上と同じアドレスからもう一度空メールが届いたときのテスト
    registration_mail = read_mail_fixture('base_mailer_notifier', 'registration')
    BaseMailerNotifier.receive(registration_mail.to_s)
    assert_not_nil BaseUser.find_by_email("example@example.com")

    # 全ユーザー数もアクティブユーザー数も増えていない
    assert_equal users_count, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size

    # 退会者から登録用メールアドレスに空メールが届いたときのテスト
    registration_mail = read_mail_fixture('base_mailer_notifier','registration_from_withdrawal')
    BaseMailerNotifier.receive(registration_mail.to_s)
    assert_not_nil BaseUser.find_by_email("test6@test.com")

    # 全ユーザー数は1増えている，アクティブユーザー数は増えていない
    assert_equal users_count + 1, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size
    users_count = BaseUser.count

    # 強制退会者から登録用メールアドレスに空メールが届いたときのテスト
    registration_mail = read_mail_fixture('base_mailer_notifier','registration_from_withdrawal')
    BaseMailerNotifier.receive(registration_mail.to_s)
    assert_not_nil BaseUser.find_by_email("test6@test.com")

    # 全ユーザー数もアクティブユーザー数も増えていない
    assert_equal users_count, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size
  end

  # ユーザ情報、プロフィール情報、ポイント情報検索を元に検索するテスト
  def test_find_users_by_all_search_info

    # 条件とくになし。削除されていない全ユーザを取得する
    users = BaseUser.find_users_by_all_search_info({:email => ['mobilesns-dev@devml.drecom.co.jp']}, {}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 1)  # 検索結果1名
    assert_equal(users[0].login, 'quentin')

    # メールアドレスが　mobilesns-dev@devml.drecom.co.jp
    # ポイントは特に意識しない
    users = BaseUser.find_users_by_all_search_info({:email => ['mobilesns-dev@devml.drecom.co.jp']}, {}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 1)  # 検索結果1名
    assert_equal(users[0].login, 'quentin')

    # 会員IDが　three　
    # ポイントは特に意識しない
    users = BaseUser.find_users_by_all_search_info({:login => ['three']}, {}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 1)  # 検索結果1名
    assert_equal(users[0].email, 'test2@test.com')

    # メールアドレスが　mobilesns-dev@devml.drecom.co.jp　で　会員IDが　three　
    # ポイントは特に意識しない
    users = BaseUser.find_users_by_all_search_info({:email => ['mobilesns-dev@devml.drecom.co.jp'], :login => ['three']}, {}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 0)  # 検索結果0名

    # メールアドレスが　mobilesns-dev@devml.drecom.co.jp　で　会員IDが　quentin　
    # ポイントは特に意識しない
    users = BaseUser.find_users_by_all_search_info({:email => ['mobilesns-dev@devml.drecom.co.jp'], :login => ['quentin']}, {}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 1)  # 検索結果1名
    assert_equal(users[0].login, 'quentin')

    # 500 ポイント以上所有している
    users = BaseUser.find_users_by_all_search_info({}, {}, {:pnt_master_id => 1, :start_point => 500}) 
    assert_not_nil users 
    assert_equal(users.size, 1)  # 検索結果1名
    assert_equal(users[0].id, 3)

    # 10 ポイント以上所有しており、かつdocomoユーザ
    users = BaseUser.find_users_by_all_search_info({:base_carrier_id => [1]}, {}, {:pnt_master_id => 1, :start_point => 10}) 
    assert_not_nil users 
    assert_equal(users.size, 2)  # 検索結果2名
    assert_equal(users[0].id, 1)
    assert_equal(users[1].id, 2)

    # 10 ポイント以上所有しており、かつdocomoかauのユーザ
    users = BaseUser.find_users_by_all_search_info({:base_carrier_id => [1,2]}, {}, {:pnt_master_id => 1, :start_point => 10}) 
    assert_not_nil users 
    assert_equal(users.size, 4)  # 検索結果3名
    assert_equal(users[0].id, 1)
    assert_equal(users[1].id, 2)
    assert_equal(users[2].id, 3)
    assert_equal(users[3].id, 4)

    # 5000 ポイント以下を所有しており、かつauユーザ
    users = BaseUser.find_users_by_all_search_info({:base_carrier_id => [2]}, {}, {:pnt_master_id => 1, :end_point => 5000}) 
    assert_not_nil users 
    assert_equal(users.size, 2)  # 検索結果1名
    assert_equal(users[0].id, 3)
    assert_equal(users[1].id, 4)

    # 男性ユーザ一覧を取得
    users = BaseUser.find_users_by_all_search_info({}, {:sex => [1]}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 1)  # 検索結果1名 性別は全員 1 (= 男性)
    assert_equal(users[0].id, 1)
    assert_equal(users[0].base_profile.sex, 1)
    
    # ニックネームに'てすと'を含むユーザー一覧を取得
    users = BaseUser.find_users_by_all_search_info({}, {:name => 'てすと'}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 3)  # 検索結果3名
    assert_equal(users[0].id, 1)
    assert_equal(users[0].base_profile.name,'てすと1')
    assert_equal(users[1].id, 2)
    assert_equal(users[1].base_profile.name,'てすと2')
    assert_equal(users[2].id, 3)
    assert_equal(users[2].base_profile.name,'てすと3')

    # docomoの男性ユーザ一覧を取得
    users = BaseUser.find_users_by_all_search_info({:base_carrier_id => [1]}, {:sex => [1]}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 1)  # 検索結果1名
    assert_equal(users[0].id, 1)
    assert_equal(users[0].base_carrier_id, 1)

    # 10 ポイント以上所有しており、かつdocomoかauの女性ユーザ
    users = BaseUser.find_users_by_all_search_info(
    {:base_carrier_id => [1,2]}, {:sex => [2]}, {:pnt_master_id => 1, :start_point => 10}) 
    assert_not_nil users 
    assert_equal(users.size, 3)  # 検索結果3名
    assert_equal(users[0].id, 2)
    assert_equal(users[0].base_profile.sex, 2)
    assert_equal(users[1].id, 3)
    assert_equal(users[1].base_profile.sex, 2)

    # 20才から26才のユーザ
    # FIXME 毎年結果がかわるのでテストとしてはよくない
    users = BaseUser.find_users_by_all_search_info({}, {:age_start => 20, :age_end => 27}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 2)  # 検索結果2名
    assert_equal(users[0].id, 4)
    assert_equal(users[1].id, 5)

    # 10日前から3日前に参加したユーザ
    users = BaseUser.find_users_by_all_search_info(
    {:joined_at_start => 10.days.ago.strftime('%Y-%m-%d'), :joined_at_end => 3.days.ago.strftime('%Y-%m-%d')}, {}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 2)  # 検索結果2名
    assert_equal(users[0].id, 1)
    assert_equal(users[1].id, 10)

    # 3日前から参加してかつ女性ユーザ
    users = BaseUser.find_users_by_all_search_info({:joined_at_start => 3.days.ago.strftime('%Y-%m-%d')}, {:sex =>[2]}, {}) 
    assert_not_nil users 
    assert_equal(users.size, 4)  # 検索結果4名
    assert_equal(users[0].id, 2)
    assert_equal(users[0].base_profile.sex, 2)
    assert_equal(users[1].id, 3)
    assert_equal(users[1].base_profile.sex, 2)
    assert_equal(users[2].id, 4)
    assert_equal(users[2].base_profile.sex, 2)
    assert_equal(users[3].id, 5)
    assert_equal(users[3].base_profile.sex, 2)
    
  end

  # 全ユーザ数を取得するテスト
  # 全ユーザ数の定義　仮登録状態を除く全ユーザ。退会者は含みます
  def test_count_all_users
    count = BaseUser.count_all_users
    assert_not_nil count 
    assert_equal(count, 10)
  end

  # 退会者数を取得するテスト
  def test_count_by_withdrawal
    count = BaseUser.count_by_withdrawal
    assert_not_nil count 
    assert_equal(count, 3)
  end

  # 友だち(≠BaseFriend)招待のテスト
  def test_invite_friend
    # 招待する側
    base_user = BaseUser.find(1)

    # 招待メッセージ
    invite_message = 'hogehoge'

    # テスト用に現在の数を取得
    users_count = BaseUser.count
    active_users_count = BaseUser.active_users.size

    # 招待してみる
    mail_address = 'invited_user@test.com'
    assert_not_nil base_user.invite_friend(mail_address, invite_message)

    # 全ユーザー数は1増えている，アクティブユーザー数は増えていない
    assert_equal users_count + 1, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size
    users_count = BaseUser.count

    # もう一度招待してみる(仮登録ユーザーを招待してみる)テスト
    assert_not_nil base_user.invite_friend(mail_address, invite_message)

    # 全ユーザー数もアクティブユーザー数も増えていない
    assert_equal users_count, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size

    # 既存ユーザー(アクティブ)を招待してみるテスト
    mail_address = 'test2@test.com'
    assert_nil base_user.invite_friend(mail_address, invite_message)

    # 全ユーザー数もアクティブユーザー数も増えていない
    assert_equal users_count, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size

    # 退会ユーザーを招待してみるテスト
    mail_address = 'test6@test.com'
    assert_not_nil base_user.invite_friend(mail_address, invite_message)

    # 全ユーザー数は1増えている，アクティブユーザー数は増えていない
    assert_equal users_count + 1, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size
    users_count = BaseUser.count

    # 強制退会ユーザーを招待してみるテスト
    mail_address = 'test7@test.com'
    assert_nil base_user.invite_friend(mail_address, invite_message)

    # 全ユーザー数もアクティブユーザー数も増えていない
    assert_equal users_count, BaseUser.count
    assert_equal active_users_count, BaseUser.active_users.size
  end

  # friend_applies のテスト
  def test_friend_applies
    # 友だち申請されていないユーザー
    current_base_user = BaseUser.find(1)
    assert_equal 0, current_base_user.friend_applies.size

    # 友だち申請されているユーザー
    current_base_user = BaseUser.find(2)
    assert_equal 2, current_base_user.friend_applies.size
  end

  # 友だちの友だちのリストのテスト
  # 1 と 2 は友だち
  # 2 と 4 は友だち
  # よって、1 と 4 は友だちの友だち
  # それ以外には友だちの友だちは存在しない
  # 6 は 2, 3 に対して友だち申請中
  # failure が出たらまず fixtures/base_friends.yml を確認
  def test_foafs
    # 友だちの友だちがひとりいる
    current_base_user = BaseUser.find(1)
    foafs = current_base_user.foafs
    assert_not_nil foafs
    assert_equal 1, foafs.length
    assert_equal 4, foafs[0].friend_id

    # 友だちの友だちがひとりいる
    current_base_user = BaseUser.find(4)
    foafs = current_base_user.foafs
    assert_not_nil foafs
    assert_equal 1, foafs.length
    assert_equal 1, foafs[0].friend_id

    # 友だちがいない
    current_base_user = BaseUser.find(6)
    foafs = current_base_user.foafs
    assert_not_nil foafs
    assert_equal 0, foafs.length
  end

  # me? のテスト
  def test_me?
    # テスト対象ユーザーの取得
    current_base_user = BaseUser.find(1)

    # 同じユーザー(のid)
    assert current_base_user.me?(1)

    # 違うユーザー(のid)
    assert_equal false, current_base_user.me?(2)
  end

  # friend? のテスト
  def test_frined?
    # 友だち
    current_base_user = BaseUser.find(2)
    assert current_base_user.friend?(1)

    # 友だちの友だち
    current_base_user = BaseUser.find(1)
    assert_equal false, current_base_user.friend?(4)

    # 申請中
    current_base_user = BaseUser.find(3)
    assert_equal false, current_base_user.friend?(1)

    # 無関係
    current_base_user = BaseUser.find(4)
    assert_equal false, current_base_user.friend?(7)
  end

  # foaf? のテスト
  # 前提条件などの詳細は上の test_foafs 参照
  def test_foaf?
    # 友だちの友だち
    current_base_user = BaseUser.find(1)
    assert current_base_user.foaf?(4)

    # 友だちの友だち
    current_base_user = BaseUser.find(4)
    assert current_base_user.foaf?(1)

    # 友だち
    current_base_user = BaseUser.find(2)
    assert_equal false, current_base_user.foaf?(1)

    # 申請中
    current_base_user = BaseUser.find(3)
    assert_equal false, current_base_user.foaf?(1)

    # 無関係
    current_base_user = BaseUser.find(4)
    assert_equal false, current_base_user.foaf?(3)
  end

  define_method('test: メルマガ受信者数を取得する') do 
    before_count = BaseUser.count_by_receive_mail_magazine
    
    base_user = BaseUser.find(1)
    base_user.receive_mail_magazine_flag = false # 非受信者を増やす
    base_user.save!
    
    after_count = BaseUser.count_by_receive_mail_magazine
    
    assert_equal(before_count - 1, after_count) # 受信者が減っている
  end
  
  define_method('test: メルマガを受信者していないユーザ数を取得する') do 
    before_count = BaseUser.count_by_reject_mail_magazine
    
    base_user = BaseUser.find(1)
    base_user.receive_mail_magazine_flag = false # 非受信者を増やす
    base_user.save!
    
    after_count = BaseUser.count_by_reject_mail_magazine
    
    assert_equal(before_count + 1, after_count) # 非受信者がふえてている
  end
  
  define_method('test: あしあとをつけるかどうかを判断する') do 
    base_user = BaseUser.find(1)
    assert_equal(base_user.footmark?, true) # 足跡をつける

    base_user = BaseUser.find(2)
    assert_equal(base_user.footmark?, false) # 足跡をつけない
  end

  define_method('test: システムからのメールを送信していいかどうかどうかを判断する') do 
    base_user = BaseUser.find(1)
    assert_equal(base_user.receive_system_mail?, true) # 送信する

    base_user = BaseUser.find(2)
    assert_equal(base_user.receive_system_mail?, false) # 送信しない
  end

  define_method('test: メルマガをを送信していいかどうかどうかを判断する') do 
    base_user = BaseUser.find(1)
    assert_equal(base_user.receive_mail_magazine?, true) # 送信する

    base_user = BaseUser.find(2)
    assert_equal(base_user.receive_mail_magazine?, false) # 送信しない
  end

  define_method('test: count_joined_at_by_period はある期間内にユーザ登録したユーザ数を取得する') do
    before_count = BaseUser.count_joined_at_by_period(Date.today-1, Date.today+1)
    
    email = "base_user_test_module@unshiu.drecom.jp"
    login = "login_test"
    user = BaseUser.new({:login => login, :email => email, :password => 'test',
                         :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :status => 2, :joined_at => Time.now,
                         :base_carrier_id => rand(4), :name => email})
    user.make_activation_code                     
    user.save
    
    after_count = BaseUser.count_joined_at_by_period(Date.today-1, Date.today+1)
    assert_equal(before_count + 1, after_count) # 増えている
  end
  
  define_method('test: count_quitted_at_by_period はある期間内に退会したユーザ数を取得する') do
    before_count = BaseUser.count_quitted_at_by_period(Date.today-1, Date.today+1)
    
    email = "base_user_test_module@unshiu.drecom.jp"
    user = BaseUser.find(1)
    user.quitted_at = Time.now
    user.status = BaseUser::STATUS_WITHDRAWAL
    user.save
    
    after_count = BaseUser.count_quitted_at_by_period(Date.today-1, Date.today+1)
    assert_equal(before_count + 1, after_count) # 増えている
  end
  
  define_method('test: count_active_at_by_date はある日付において有効だったユーザ数を取得する') do
    before_count = BaseUser.count_active_at_by_date(Date.today)
    
    1.upto(5) do |i|
      email = "base_user_test_module#{i}@unshiu.drecom.jp"
      login = "login_test_#{i}"
      user = BaseUser.new({:login => login, :email => email, :password => 'test',
                           :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :status => 2, :joined_at => Time.now,
                           :base_carrier_id => rand(4), :name => email})
      user.make_activation_code                     
      user.save!
    end
    
    user = BaseUser.find(1)
    user.quitted_at = Time.now
    user.status = BaseUser::STATUS_WITHDRAWAL
    user.save
    
    after_count = BaseUser.count_active_at_by_date(Date.today)
    assert_equal(before_count + 5 - 1, after_count) # 5人入会して、１人減ったので
  end
  
  define_method('test: かんたんログインができる') do 
    uid = '012345678912345' # テストデータとして存在している
    base_user = BaseUser.authenticate_by_uid(uid)
    assert_not_nil base_user

    uid = 'not_exists_uid'
    assert_nil BaseUser.authenticate_by_uid(uid)

    uid = nil
    assert_nil BaseUser.authenticate_by_uid(uid)
  end

  define_method('test: 最終ログイン時刻を取得する') do 
    # 事前処理：最終時刻更新
    BaseLatestLogin.update_latest_login(1)
    
    base_user = BaseUser.find(1)
    assert_not_nil(base_user.latest_login)
  end
  
  define_method('test: 一度もログインしていない場合、最終ログイン時刻はnil') do 
    base_latest_login = BaseLatestLogin.find_by_base_user_id(3)
    base_latest_login.destroy if base_latest_login # 念のため削除しておく
    
    base_user = BaseUser.find(3)
    assert_nil(base_user.latest_login)
  end
  
  ############# 以下、acts_as_authenticated 生成のテスト ##################

  def test_should_create_base_user
    assert_difference 'BaseUser.count' do
      base_user = create_base_user
      assert !base_user.new_record?, "#{base_user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_password
    assert_no_difference 'BaseUser.count' do
      u = create_base_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_email
    assert_no_difference 'BaseUser.count' do
      u = create_base_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    base_users(:quentin).update_attributes(:password => 'newpassword', :password_confirmation => 'newpassword')
    assert_equal base_users(:quentin), BaseUser.authenticate('quentin', 'newpassword')
  end

  def test_should_not_rehash_password
    base_users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal base_users(:quentin), BaseUser.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_base_user
    assert_equal base_users(:quentin), BaseUser.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    base_users(:quentin).remember_me
    assert_not_nil base_users(:quentin).remember_token
    assert_not_nil base_users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    base_users(:quentin).remember_me
    assert_not_nil base_users(:quentin).remember_token
    base_users(:quentin).forget_me
    assert_nil base_users(:quentin).remember_token
  end

protected
  def create_base_user(options = {})
    BaseUser.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end

end