# メール投稿につかう処理をまとめたクラス
# ユーザーへのメールはこのクラス、管理者へのメールは MngMailerNotifier を使う
module BaseMailerNotifierModule
  
  @@default_charset='iso-2022-jp'
  @@charset='iso-2022-jp'
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        const_set('CTYPE_TO_EXT', {'image/jpeg' => 'jpeg', 'image/gif'  => 'gif', 'image/png'  => 'png'})
        const_set('CTYPE_IMAGE', ['image/jpeg', 'image/gif' , 'image/png'])
      end
    end
  end

  module ClassMethods
    # システムメール受信フラグを見て、false なら送らない
    # ただし、引き数の最後に :force がついていればフラグに関係なく送る
    # また、メールアドレスに該当するユーザーがいない場合も送る
    # create_ で始まるメソッドの動作には関係しない
    def method_missing(method_symbol, *parameters)#:nodoc:
      case method_symbol.id2name
        when /^deliver_([_a-z]\w*)/
          force = false
          if parameters.last == :force
            parameters.pop
            force = true
          end
          tmp = new($1, *parameters)
          user = BaseUser.find_by_email(tmp.mail.to.first)
          if !force && user && !user.receive_system_mail_flag
            return nil
          end
          tmp.deliver!
        else super
      end
    end
    
    # 投稿用メールアドレス取得
    # DB に同じ情報のデータがあればそれを返し、なければ新しく作ってそれを返す
    def mail_address(base_user_id, model_name, method_name, model_id)
      info = BaseMailDispatchInfo.find_by_dispatch(base_user_id, model_name, method_name, model_id)
      return info.mail_address if info
    
      info = save_dispatch_info(base_user_id, model_name, method_name, model_id)
      info.mail_address
    end
    
    def image?(attachment)
      BaseMailerNotifier::CTYPE_IMAGE.include?(attachment.content_type)
    end
    
  private 
    
    def save_dispatch_info(base_user_id, model_name, method_name, model_id)
      mail_address = make_mail_address(model_name)
      info = BaseMailDispatchInfo.find_by_mail_address(mail_address)
      
      until info.nil? do
        mail_address = make_mail_address(method_name)
        info = BaseMailDispatchInfo.find_by_mail_address(mail_address)
      end
      
      info = BaseMailDispatchInfo.new({:model_name => model_name, :method_name => method_name,
                                       :base_user_id => base_user_id, :model_id => model_id,
                                       :mail_address => mail_address})
      info.save

      return info
    end

    def make_mail_address(model_name)
      model_keys = model_name.scan(/[A-Z]/)
      model_key_name = ""
      model_keys.each {|model_key| model_key_name = model_key_name + model_key }
      
      "u#{model_key_name.downcase}#{make_activation_code}@#{ActionMailer::Base.smtp_settings[:domain]}"
    end

    def make_activation_code
      sprintf("%03d", rand(100)) + Time.now.to_i.to_s
    end
    
  end
  
  #----------------------------------------------------------
  # send mail methods 
  #----------------------------------------------------------
  
  # 仮登録時送信メール
  # _param1_:: base_user
  def send_registration_url(base_user)
    body_from_db = setup_email('send_registration_url', base_user.email)
    @recipients  = base_user.email
    
    url = "http://#{AppResources[:init][:application_domain]}/base_signup/ask_agreement/#{base_user.activation_code}"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 仮登録時送信テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_send_registration_url(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address
    
    url = "http://#{AppResources[:init][:application_domain]}/base_signup/ask_agreement/xxxxxxx"
    @body = ERB.new(body_from_db).result(binding)    
  end
  
  # 仮登録送信元アドレスが登録済みだった場合のメール
  # _param1_:: base_user
  def already_registed(base_user)
    body_from_db = setup_email('already_registed', base_user.email)
    @recipients  = base_user.email
    
    url = "http://#{AppResources[:init][:application_domain]}/base/index"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 仮登録送信元アドレスが登録済みだった場合のテスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_already_registed(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address
    
    url = "http://#{AppResources[:init][:application_domain]}/base/index"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # ユーザ登録完了メール
  # _param1_:: base_user
  def send_complete_registration(base_user)
    body_from_db = setup_email('send_complete_registration', base_user.email)
    @recipients  = base_user.email
    
    url = "http://#{AppResources[:init][:application_domain]}/base/index"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # ユーザ登録完了のテスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_send_complete_registration(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address
    
    url = "http://#{AppResources[:init][:application_domain]}/base/index"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # メールアドレス変更メール
  # _param1_:: base_user
  def mail_reset(base_user)
    body_from_db = setup_email('mail_reset', base_user.new_email)
    @recipients  = base_user.new_email
    
    url = "http://#{AppResources[:init][:application_domain]}/base_user_config/mail_reset/#{base_user.activation_code}"
    @body = ERB.new(body_from_db).result(binding)
  end

  # メールアドレス変更テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_mail_reset(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address
    
    url = "http://#{AppResources[:init][:application_domain]}/base_user_config/mail_reset/xxxxxxxxxxxxxx"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 友達申請メール
  # _param1_:: base_friend　申請先ユーザ
  # _param2_:: apply_message 申請メッセージ
  def friend_apply_message(base_friend, apply_message)
    body_from_db = setup_email('friend_apply_message', base_friend.friend.email)
    @recipients  = base_friend.friend.email
    
    from = base_friend.base_user
    to_name = base_friend.friend.show_name
    message = apply_message
    url = "http://#{AppResources[:init][:application_domain]}/base_friend_apply/permit_or_deny/#{base_friend.id}"
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # 友達申請テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_friend_apply_message(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address
    
    from = "[送信元名]"
    to_name = "[友達申請先名]"
    message = "[申請メッセージ]"
    url = "http://#{AppResources[:init][:application_domain]}/base_friend_apply/permit_or_deny/xxxxxxxx"

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # ユーザ招待メール
  # _param1_:: inviter　招待したユーザ
  # _param2_:: temporary_user　招待されたユーザ
  # _param3_:: invite_message 招待メッセージ
  def invite_to_service(inviter, temporary_user, invite_message)
    body_from_db = setup_email('invite_to_service', temporary_user.email)
    @recipients  = temporary_user.email
    
    from = inviter
    message = invite_message
    url = "http://#{AppResources[:init][:application_domain]}/base_signup/ask_agreement/#{temporary_user.activation_code}?invite=#{inviter.id}"
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # ユーザ招待テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_invite_to_service(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address
    
    from = "[招待者名]"
    message = "[招待メッセージ]"
    url = "http://#{AppResources[:init][:application_domain]}/base_signup/ask_agreement/xxxxxx?invite=xxxx"
    
    @body = ERB.new(body_from_db).result(binding)
  end
    
  # パスワード再設定
  # _param1_:: base_user
  def password_remind(base_user)
    body_from_db = setup_email('password_remind', base_user.email)
    @recipients  = base_user.email

    url = "http://#{AppResources[:init][:application_domain]}/base_signup/password_set_ask/#{base_user.activation_code}"
    
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # パスワード再設定テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_password_remind(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    url = "http://#{AppResources[:init][:application_domain]}/base_signup/password_set_ask/xxxxxxxxxxx"
    
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 投稿失敗通知　原因が想定外の場合でわからない場合に利用される
  # _param1_:: email
  def failure_receiving_mail(email)
    body_from_db = setup_email('failure_receiving_mail', email.from)
    @recipients  = email.from
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # 投稿失敗通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_failure_receiving_mail(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 日記投稿成功通知
  # _param1_:: email
  # _param2_:: dia_entry_id 記事ID
  def success_saving_dia_entry(email, dia_entry_id)
    body_from_db = setup_email('success_saving_dia_entry', email.from)
    @recipients  = email.from
    
    title = email.subject.toutf8
    url = "http://#{AppResources[:init][:application_domain]}/dia_entry/show/#{dia_entry_id}"
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # 日記投稿成功通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_success_saving_dia_entry(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    title = "[日記記事タイトル]"
    url = "http://#{AppResources[:init][:application_domain]}/dia_entry/show/xxxxxx"

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 日記投稿失敗通知
  # _param1_:: email
  # _param2_:: reason 失敗理由
  def failure_saving_dia_entry(email, reason = nil)
    body_from_db = setup_email('failure_saving_dia_entry', email.from)
    @recipients  = email.from

    @body = ERB.new(body_from_db).result(binding)
  end

  # 日記投稿失敗通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_failure_saving_dia_entry(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    @body = ERB.new(body_from_db).result(binding)
  end

  # 日記記事にコメントがついたことを記事投稿者に通知
  # _param1_:: entry
  # _param2_:: base_user
  def notify_dia_entry_commented(entry, base_user)
    body_from_db = setup_email('notify_dia_entry_commented', entry.dia_diary.base_user.email)
    @recipients  = entry.dia_diary.base_user.email
    
    commented_name = base_user.show_name
    entry_title = entry.title
    url = "http://#{AppResources[:init][:application_domain]}/dia_entry/show/#{entry.id}"

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 日記記事にコメントがついたことを記事投稿者に通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_notify_dia_entry_commented(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    commented_name = "[コメント者名]"
    entry_title = "[記事タイトル]"
    url = "http://#{AppResources[:init][:application_domain]}/dia_entry/show/xxxxx"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 写真投稿成功通知
  # _param1_:: email
  # _param2_:: abm_album_id 
  def success_saving_abm_images(email, abm_album_id)
    body_from_db = setup_email('success_saving_abm_images', email.from)
    @recipients  = email.from
    
    title = title.blank? ? '（タイトルなし）' : email.subject
    url = "http://#{AppResources[:init][:application_domain]}/abm_album/show/#{abm_album_id}"
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # 写真投稿成功通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_success_saving_abm_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    title = "[画像タイトル]"
    url = "http://#{AppResources[:init][:application_domain]}/abm_album/show/xxxxx"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 写真投稿失敗通知
  # _param1_:: email
  # _param2_:: reason 失敗理由
  def failure_saving_abm_images(email, reason = nil)
    body_from_db = setup_email('failure_saving_abm_images', email.from)
    @recipients  = email.from
    
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 写真投稿失敗テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_failure_saving_abm_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # プロフィール画像保存完了通知
  # _param1_:: email
  # _param2_:: base_user_id
  def success_saving_base_profile_images(email, base_user_id)
    body_from_db = setup_email('success_saving_base_profile_images', email.from)
    @recipients  = email.from
    
    url = "http://#{AppResources[:init][:application_domain]}/base_profile/show/#{base_user_id}"
    
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # 写真投稿失敗テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_success_saving_base_profile_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    url = "http://#{AppResources[:init][:application_domain]}/base_profile/show/xxxxxxxxxx"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # プロフィール画像保存失敗通知
  # _param1_:: email
  # _param2_:: reason 失敗理由
  def failure_saving_base_profile_images(email, reason = nil)
    body_from_db = setup_email('failure_saving_base_profile_images', email.from)
    @recipients  = email.from
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # プロフィール画像保存失敗通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_failure_saving_base_profile_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # プロフ画像保存保存完了通知
  # _param1_:: email
  # _param2_:: base_user_id
  def success_saving_prf_images(email, base_user_id)
    body_from_db = setup_email('success_saving_prf_images', email.from)
    @recipients  = email.from
    
    url = "http://#{AppResources[:init][:application_domain]}/prf/show/#{base_user_id}"
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # プロフ画像保存保存完了通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_success_saving_prf_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    url = "http://#{AppResources[:init][:application_domain]}/prf/show/xxxxxx"
    @body = ERB.new(body_from_db).result(binding)
  end
  
  # プロフ画像保存失敗通知
  # _param1_:: email
  # _param2_:: reason 失敗理由
  def failure_saving_prf_images(email, reason = nil)
    body_from_db = setup_email('failure_saving_prf_images', email.from)
    @recipients  = email.from
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # プロフ画像保存失敗通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_failure_saving_prf_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    @body = ERB.new(body_from_db).result(binding)
  end

  # コミュニティ画像保存完了通知
  # _param1_:: email
  # _param2_:: cmm_community_id
  def success_saving_cmm_images(email, cmm_community_id)
    body_from_db = setup_email('success_saving_cmm_images', email.from)
    @recipients  = email.from
    
    name = CmmCommunity.find(cmm_community_id).name
    url = "http://#{AppResources[:init][:application_domain]}/cmm/show/#{cmm_community_id}"
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # コミュニティ画像保存完了通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_success_saving_cmm_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    name = "[コミュニティ名]"
    url = "http://#{AppResources[:init][:application_domain]}/cmm/show/xxxxxx"

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # コミュニティ画像保存失敗通知
  # _param1_:: email
  # _param2_:: reason 失敗理由
  def failure_saving_cmm_images(email, reason = nil)
    body_from_db = setup_email('failure_saving_cmm_images', email.from)
    @recipients  = email.from
    
    @body = ERB.new(body_from_db).result(binding)
  end

  # コミュニティ画像保存失敗通知テスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_failure_saving_cmm_images(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    @body = ERB.new(body_from_db).result(binding)
  end
  
  # メッセージのお知らせ
  # _param1_:: message
  # _param2_:: sender
  # _param3_:: receiver
  def notify_receiving_message(message, sender, receiver)
    body_from_db = setup_email('notify_receiving_message', receiver.email)
    @recipients  = receiver.email
    
    to_name = receiver.show_name
    from = sender
    message = message
    url = "http://#{AppResources[:init][:application_domain]}/msg_receiver/show/#{message.id}"

    @body = ERB.new(body_from_db).result(binding)
  end

  # メッセージのお知らせテスト配信用メール
  # _param1_:: base_mail_template
  # _param2_:: mail_address 送信先
  def send_test_notify_receiving_message(base_mail_template, mail_address)
    body_from_db = setup_from_base_mail_template(base_mail_template)
    @recipients  = mail_address

    to_name = "[送信先]"
    from = "[送信元]"
    message = "[メッセージ内容]"
    url = "http://#{AppResources[:init][:application_domain]}/msg_receiver/show/xxxxxxxxx"
    @body = ERB.new(body_from_db).result(binding)
  end
  
protected
  
  # emailの基礎設定をする
  # _param1_:: action_name
  # _param2_:: mail_address
  # return:: データベースに登録ているテンプレート本文
  def setup_email(action_name, mail_address)
    mail_address = mail_address[0] if mail_address.instance_of?(Array)
    carrier = Jpmobile::Email.detect(mail_address)
    device_type = carrier.nil? ? BaseMailTemplate::DEVICE_TYPE_PC : BaseMailTemplate::DEVICE_TYPE_MOBILE
    base_mail_template = BaseMailTemplate.find_active_mail_template_by_action_name_and_device_type(action_name, device_type)
    return setup_from_base_mail_template(base_mail_template)
  end
  
  # base_mail_templateからemailの基礎設定をする
  # _param1_:: base_mail_template
  # return:: データベースに登録ているテンプレート本文
  def setup_from_base_mail_template(base_mail_template)
    @from         = AppResources[:base][:system_mail_address]
    @subject      = base_mail_template.subject
    @sent_on      = Time.now
    @content_type = base_mail_template.content_type
    @headers      = {'return-path' => AppResources[:init][:return_path_adddress]}
    
    body_from_db = base_mail_template.body
    if base_mail_template.footer?
      footer_template = BaseMailTemplate.find_active_mail_template_by_action_name_and_device_type('footer', base_mail_template.device_type)
      body_from_db.concat(footer_template.body)
    end
    
    return body_from_db
  end
  
  def ext( mail )
    CTYPE_TO_EXT[mail.content_type] || 'txt'
  end
  
end

module TMail
  class Mail
    def plain_body
      if self.multipart?
        body = self.parts.find{|part| part.content_type == "text/plain"}
      else
        body = self.content_type == "text/plain" ? self : nil
      end
      
      if body
        result = body.body
        result = result.toutf8 if result.match(/^\e/)
        result
      else
        nil
      end
    end
  end
end