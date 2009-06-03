#
# == 概要
# ユーザのメール投稿と受信の処理
#　システム管理者のメール系の処理は MngMailerNotifier を使う
class BaseMailerNotifier < ActionMailer::Base
  include BaseMailerNotifierModule
  include BaseMailerReceptModule
end
