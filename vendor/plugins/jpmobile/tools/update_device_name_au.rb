#!/usr/bin/env ruby -Ku
# auのwebページから機種名を取得するスクリプト。

require 'rubygems'
require 'kconv'
require 'open-uri'
require 'hpricot'
require 'pp'


uri = "http://www.au.kddi.com/ezfactory/tec/spec/4_4.html" 
h = Hpricot(URI(uri).read.toutf8)

table = {}
(h/"//table//tr").each do |tr|
  if tr
    device_name = ""
    (tr/"td/div[@class='TableText']").each_with_index do |td, index|
      break unless td.inner_html =~ /^[A-Za-z]./
      value = td.inner_html.gsub(/<br \/>|\s/, '')
      if index % 2 == 0
        device_name = value
      else
        device_ids = value.split("/")
        device_ids.each { |device_id| table[device_id] = device_name }
      end
    end
  end
end

# 書き出し
open("lib/jpmobile/mobile/z_device_name_au.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Au::DEVICE_NAME = "
  f.puts table.pretty_inspect
end