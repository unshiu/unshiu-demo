require File.dirname(__FILE__) + '/../test_helper'

module MngMailerNotifierTestModule

  define_method('test: 問い合わせメールを管理者に送る') do 
    mail = MngMailerNotifier.create_inquire_to_manager("unshiu@drecom.co.jp", "問題", "http://referer")
    assert_match /unshiu@drecom.co.jp/, mail.body
    assert_match /問題/, mail.body
    assert_match /http:\/\/referer/, mail.body
  end

  define_method('test: ポイント一括処理が終わった際に送られるメールを送信する') do 
    mail = MngMailerNotifier.create_pnt_import_finished
    assert_match /一括配布のcsvファイルの処理が終わりました/, mail.body
  end
  
end
