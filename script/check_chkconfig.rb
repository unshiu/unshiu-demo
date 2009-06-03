#!/usr/bin/env ruby
#
# chkconfi結果をファイルに出力　cap経由で利用される
#　引数１：検索対象
#　引数２：出力ディレクトリ

host_name = %x( uname -n )
system "chkconfig --list | grep #{ARGV[0]} > #{ARGV[1]}/chkconfig-#{host_name}"