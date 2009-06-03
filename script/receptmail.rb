#!/usr/bin/env ruby
#
# メール受信処理
#　postfixなどから呼ばれることを想定

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'application'

BaseMailerNotifier::receive(STDIN.read)
