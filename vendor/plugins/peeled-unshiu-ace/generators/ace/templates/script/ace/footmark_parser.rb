#!/usr/bin/env ruby

#
# 足跡情報を解析してDBへ挿入する

require File.dirname(__FILE__) + '/../../config/boot'
require File.dirname(__FILE__) + '/../../config/environment'

require File.expand_path(File.dirname(__FILE__) + '/../../lib/ace/ace_log_system.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/app_resources.rb')

db = AceLogSystem::Database::Base.new
loop do
  parser = AceLogSystem::Parser::Base.new
  parser.logs.each do | file |
    db.footmark_process(file)
  end
  GC.start
  sleep(60)
end
db.close