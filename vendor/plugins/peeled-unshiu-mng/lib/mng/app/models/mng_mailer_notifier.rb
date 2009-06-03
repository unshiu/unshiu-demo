#
# 運用管理者宛のメール送信をする
#
module MngMailerNotifierModule
  
  class << self
    def included(base)
      base.class_eval do
        #include ActionMailerWithGetTextPatch
      end
    end
  end
  
  @@default_charset='iso-2022-jp'
  @@charset='iso-2022-jp'
  
  # お問い合わせメールを管理者に送る
  def inquire_to_manager(mail_address, body, referer)
    @recipients  = AppResources["mng"]["manager_mail_address"]
    @from        = AppResources["base"]["system_mail_address"]
    @subject     = "mobilesns お問い合わせ"
    @sent_on     = Time.now
    @body[:mail_address] = mail_address
    @body[:body] = body
    @body[:referer] = referer
  end
  
  # ポイント一括更新処理が終了した際に運用管理者へ送るメール
  def pnt_import_finished
    @recipients  = AppResources["mng"]["manager_mail_address"]
    @from        = AppResources["base"]["system_mail_address"]
    @subject     = " ポイント一括更新処理完了のお知らせ"
    @sent_on     = Time.now
  end
  
end
