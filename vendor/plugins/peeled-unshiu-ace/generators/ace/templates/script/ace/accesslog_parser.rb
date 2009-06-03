#!/usr/bin/env ruby

#
# アクセス情報を解析してDBへ挿入する
#　起動例）　ruby parser.rb

require File.dirname(__FILE__) + '/../../config/boot'
require File.dirname(__FILE__) + '/../../config/environment'

require File.expand_path(File.dirname(__FILE__) + '/../../lib/ace/ace_log_system.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/app_resources.rb')

log = AceLogSystem::Logger.new
db = AceLogSystem::Database::Base.new
loop do
  parser = AceLogSystem::Parser::Base.new
  parser.logs.each do | file |
    db.access_log_process(file)
  end
  sleep(60)
end
db.close