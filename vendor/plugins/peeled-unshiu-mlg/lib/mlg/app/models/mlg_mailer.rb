#
# メールマガジン
#
module MlgMailerModule
  
  class << self
    def included(base)
      base.class_eval do
        #include ActionMailerWithGetTextPatch
        
        @@default_charset='iso-2022-jp'
        @@charset='iso-2022-jp'
      end
    end
  end
  
  # メールマガジンを送信する
  # _param1_:: base_user ユーザ情報
  # _param2_:: mlg_magazine 対象メール　
  def mail_magazine(base_user, mlg_magazine)
    @recipients  = base_user.email
    @from        = AppResources["mlg"]["send_from"]
    @subject     = mlg_magazine.title
    @sent_on     = Time.now
    @body[:message] = mlg_magazine.body
  end
  
end
