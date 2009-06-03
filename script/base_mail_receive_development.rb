#!/usr/bin/env ruby
#
# 開発環境用に擬似的にメールを投稿処理をする
#　起動例）　ruby base_mail_receive_development filename
#
require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'application'

email = IO.readlines("#{RAILS_ROOT}/test/fixtures/base_mailer_notifier/development/#{ARGV[0]}.txt")
BaseMailerNotifier.receive(email.to_s)
