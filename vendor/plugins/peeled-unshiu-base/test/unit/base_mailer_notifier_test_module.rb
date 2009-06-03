require File.dirname(__FILE__) + '/../test_helper'
require 'base_mailer_notifier'

module BaseMailerNotifierTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        include ActionMailer::Quoting
        include TestUtil::Base::UnitTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_mail_dispatch_infos
        fixtures :base_mail_templates
        fixtures :base_mail_template_kinds
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :cmm_communities
      end
    end
  end
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    
    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => "utf-8" }
  end
  
  # メール受信テスト
  # BaseProfile の receive テストが正常に動けば問題ないのでそちらで代用します
  
  # 仮登録空メールの受信と、本登録URL記載メール送信のテスト
  def test_send_registration_url
    registration_mail = read_mail_fixture('base_mailer_notifier', 'registration')
    BaseMailerNotifier.receive(registration_mail.to_s)
    user = BaseUser.find_by_email("mobilesns-dev@devml.drecom.co.jp")    
    
    mail = BaseMailerNotifier.create_send_registration_url(user)
    assert_not_nil mail.body.index("#{user.activation_code}")
  end
  
  # プロフィール画像投稿失敗メール送信のテスト
  def test_failure_saving_base_profile_images
    mail = TMail::Mail.new
    mail.from = ['mobilesns-dev@devml.drecom.co.jp']
    BaseMailerNotifier.deliver_failure_saving_base_profile_images(mail)
    BaseMailerNotifier.deliver_failure_saving_base_profile_images(mail, '添付されたファイルが画像ではありません。')
  end
  
  # 投稿用メールアドレス取得テスト
  def test_mail_address
    # すでに DB にある場合
    assert_equal "test1@test", BaseMailerNotifier.mail_address(1, 'DiaEntry', 'receive', 1)
    
    # DB にない場合
    assert_not_equal "test1@test", BaseMailerNotifier.mail_address(2, 'DiaEntry', 'receive', 1)
  end
  
  # 画像判定のテスト
  def test_image?
    attachment = TMail::Attachment.new
    
    # 画像として判定するもの
    attachment.content_type = 'image/jpeg'
    assert BaseMailerNotifier.image?(attachment)
    attachment.content_type = 'image/gif'
    assert BaseMailerNotifier.image?(attachment)
    attachment.content_type = 'image/png'
    
    #　画像として判定しないもの
    assert BaseMailerNotifier.image?(attachment)
    attachment.content_type = 'image/ief' # よくわからん画像
    assert ! BaseMailerNotifier.image?(attachment)
    attachment.content_type = 'video/mpeg' # mpeg 動画
    assert ! BaseMailerNotifier.image?(attachment)
  end
  
  define_method('test: ...(3つの)を含むメールアドレスへの送信をする') do 
    user = BaseUser.new
    user.email = 'hoge....hoge@unshiu.drecom.jp'
    mail = BaseMailerNotifier.create_send_registration_url(user)
    assert_not_nil mail.to
  end
  
  define_method('test: @の直前に.を含むメールアドレスへの送信をする') do 
    user = BaseUser.new
    user.email = 'hogehoge.@unshiu.drecom.jp'
    mail = BaseMailerNotifier.create_send_registration_url(user)
    assert_not_nil mail.to
  end
  
  define_method('test: 仮登録受付メールはDBのテンプレートを利用する') do 
    user = BaseUser.new
    user.email = 'test@docomo.ne.jp'
  
    mail = BaseMailerNotifier.create_send_registration_url(user)
    assert_not_nil mail.to
  
    assert_equal(mail.body, "仮登録して頂きありがとうございます。\n以下の URL から本登録を行ってください。\n\nhttp://localhost:3000/base_signup/ask_agreement/\n(C)DRECOM\n")
    assert_equal(mail.header['return-path'].addr.address, "root@unshiu.drecom.jp")
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定した仮登録受付メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_send_registration_url(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
  end
  
  define_method('test: 登録済みメールはDBのテンプレートを利用する') do 
    user = BaseUser.new
    user.email = 'test@unshiu.drecom.jp'
    mail = BaseMailerNotifier.create_already_registed(user)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定した登録済みメールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_already_registed(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 登録完了メールはDBのテンプレートを利用する') do 
    user = BaseUser.new
    user.email = 'test@unshiu.drecom.jp'
    mail = BaseMailerNotifier.create_send_complete_registration(user)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定した登録完了メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_send_complete_registration(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: メールアドレス変更メールはDBのテンプレートを利用する') do 
    user = BaseUser.new
    user.new_email = 'test@unshiu.drecom.jp'
    mail = BaseMailerNotifier.create_mail_reset(user)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定したメールアドレス変更メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_mail_reset(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 友達申請メールはDBのテンプレートを利用する') do 
    friend = BaseFriend.find(1)
    
    mail = BaseMailerNotifier.create_friend_apply_message(friend, "友達になってください")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定した友達申請メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_friend_apply_message(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: ユーザ招待メールはDBのテンプレートを利用する') do 
    invite_user = BaseUser.new
    invite_user.email = 'test_from@unshiu.drecom.jp'
    
    temporary_user = BaseUser.new
    temporary_user.email = 'test_to@unshiu.drecom.jp'
    
    mail = BaseMailerNotifier.create_invite_to_service(invite_user, temporary_user, "招待")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定したユーザ招待メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_invite_to_service(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: パスワード再設定メールはDBのテンプレートを利用する') do 
    user = BaseUser.new
    user.email = 'test@unshiu.drecom.jp'
    
    mail = BaseMailerNotifier.create_password_remind(user)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定したパスワード再設定メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_password_remind(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 投稿失敗通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_failure_receiving_mail(email)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定した投稿失敗通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_failure_receiving_mail(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 日記投稿成功通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')

    mail = BaseMailerNotifier.create_success_saving_dia_entry(email, 1)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定した日記投稿成功通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_success_saving_dia_entry(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 日記投稿失敗通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
  
    mail = BaseMailerNotifier.create_failure_saving_dia_entry(email, "失敗しました")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定した日記投稿失敗通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_failure_saving_dia_entry(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 日記記事にコメントがついたことを記事投稿者に通知メールはDBのテンプレートを利用する') do 
    entry = DiaEntry.find(1)
    user = BaseUser.new
    user.email = 'test@unshiu.drecom.jp'
    
    mail = BaseMailerNotifier.create_notify_dia_entry_commented(entry, user)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定した日記記事にコメントがついたことを記事投稿者に通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_notify_dia_entry_commented(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 写真投稿成功通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_success_saving_abm_images(email, 1)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定した写真投稿成功通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_success_saving_abm_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 写真投稿失敗通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_failure_saving_abm_images(email, "失敗しました")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定した写真投稿失敗通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_failure_saving_abm_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: プロフィール画像保存完了通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_success_saving_base_profile_images(email, 1)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定したプロフィール画像保存完了通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_success_saving_base_profile_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: プロフィール画像保存失敗通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_failure_saving_base_profile_images(email, "失敗しました")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定したプロフィール画像保存失敗通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_failure_saving_base_profile_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: プロフ画像保存完了通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_success_saving_prf_images(email, 1)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定したプロフ画像保存完了通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_success_saving_prf_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: プロフ画像保存失敗通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_failure_saving_prf_images(email, "失敗しました")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定したプロフ画像保存失敗通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_failure_saving_prf_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: コミュニティ画像保存完了通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_success_saving_cmm_images(email, 1)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定したコミュニティ画像保存完了通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_success_saving_cmm_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: コミュニティ画像保存失敗通知メールはDBのテンプレートを利用する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    
    mail = BaseMailerNotifier.create_failure_saving_cmm_images(email, "失敗しました")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end

  define_method('test: 管理画面からテンプレートと送信先を指定したコミュニティ画像保存失敗通知メールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_failure_saving_cmm_images(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end  
    
  define_method('test: メッセージのお知らせメールはDBのテンプレートを利用する') do 
    sender = BaseUser.new
    sender.name = "drecom"
    
    receiver = BaseUser.new
    receiver.email = "test@unshiu.drecom.jp"
    receiver.name = "drecom2"
    
    message = MsgMessage.new
    message.title = "message"
    
    mail = BaseMailerNotifier.create_notify_receiving_message(message, sender, receiver)
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  define_method('test: 管理画面からテンプレートと送信先を指定したメッセージのお知らせメールのテスト配信ができる') do 
    base_mail_template = BaseMailTemplate.find(1)
    
    mail = BaseMailerNotifier.create_send_test_notify_receiving_message(base_mail_template, "test@unshiu.drecom.co.jp")
    assert_not_nil mail.to
    assert_not_nil(mail.subject)
    assert_not_nil(mail.body)
  end
  
  
private
  
  def encode(subject)
    quoted_printable(subject, CHARSET)
  end

end