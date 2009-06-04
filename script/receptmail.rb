#!/usr/local/bin/ruby
#
# メール受信処理
#　postfixなどから呼ばれることを想定

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

BaseMailerNotifier::receive(STDIN.read)
