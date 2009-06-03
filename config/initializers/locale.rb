# 翻訳ファイルが置かれているディレクトリを指定します。
I18n.load_path += Dir[ File.join(RAILS_ROOT, 'config', 'locales', '*.{rb,yml}') ]

# デフォルトのロケールを設定します。"en"以外を指定したい場合のみ、この値を使用します。
# Ruby-Localeでは優先度のもっとも低いロケールとしてこの値が使われます。
I18n.default_locale = "ja-JP" 

# このアプリケーションが単一のロケールのみを使う場合はI18n.default_localeとともに、
# Locale.defaultを指定してください。この設定はRuby-Localeでロケールを強制的に指定するものです。
Locale.default = "ja-JP"