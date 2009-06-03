module ActionMailerWithGetTextPatch
  # GetText 拡張。UTF8の機種依存文字が含まれる場合に文字化けするのを防ぐ
  def base64(text, charset="iso-2022-jp", convert=true)
    if convert
      if charset == "iso-2022-jp"
        text = NKF.nkf('-j --cp932 -m0', text)
      end
    end
    text = TMail::Base64.folding_encode(text)
    "=?#{charset}?B?#{text}?="
  end
  
  # GetText 拡張。UTF8の機種依存文字が含まれる場合に文字化けするのを防ぐ
  def create!(*arg) #:nodoc:
    create_without_gettext!(*arg)
    if Locale.get.language == "ja"
      require 'nkf'
      @mail.subject = base64(@mail.subject)
      part = @mail.parts.empty? ? @mail : @mail.parts.first
      if part.content_type == 'text/plain'
        part.charset = 'iso-2022-jp'
        part.body = NKF.nkf('-j --cp932', part.body)
      end
    end
    @mail
  end
end