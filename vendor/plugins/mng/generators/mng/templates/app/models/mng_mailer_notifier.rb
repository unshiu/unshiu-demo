#
# 運用管理者宛のメール送信をする
#
class MngMailerNotifier < ActionMailer::Base
  include MngMailerNotifierModule
end
