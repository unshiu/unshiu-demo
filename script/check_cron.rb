#!/usr/bin/env ruby
#
# cron設定をファイルに出力　cap経由で利用される
#　引数1：出力ディレクトリ

host_name = %x( uname -n )
system "crontab -l > #{ARGV[0]}/cron-#{host_name}"