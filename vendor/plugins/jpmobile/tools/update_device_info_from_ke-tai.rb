#!/usr/bin/env ruby -Ku
# ke-tai.orgのwebページから機種名を取得するスクリプト。

require 'rubygems'
require 'kconv'
require 'open-uri'
require 'fastercsv'
require 'pp'

src = open("http://ke-tai.org/moblist/csv_down.php").read.toutf8

INDEX_CARRIER        = 1  # キャリア名
INDEX_DEVICE_NAME    = 2  # 機種名
INDEX_DEVICE_ID      = 3  # デバイスID
INDEX_GIF            = 11 # GIF画像を閲覧できるか
INDEX_JPG            = 12 # JPG画像を閲覧できるか
INDEX_PNG            = 13 # PNG画像を閲覧できるか
INDEX_FLASH          = 14 # Flashを利用できるか
INDEX_FLASH_VERSION  = 15 # Flashバージョン
INDEX_SSL            = 20 # SSLが利用できるか
INDEX_CSS            = 23 # CSSが利用できるかどうか
INDEX_GPS            = 24 # GPSが利用できるかどうか

docomo = {}
au = {}
softbank = {}
emobile = {}

def boolean_convert(value)
  value == "1" ? true : false
end
  
arryas = FasterCSV.parse(src)
arryas.each_with_index do |array, index|
  next if index < 2
  
  device_ids = array[INDEX_DEVICE_ID].split("/") # 
  device_ids.each do |device_id|
    device_id.strip!
    
    flash_version = array[INDEX_FLASH_VERSION] == "" ? nil : array[INDEX_FLASH_VERSION]
    
    info = { :name => array[INDEX_DEVICE_NAME], :gif => boolean_convert(array[INDEX_GIF]), :jpg => boolean_convert(array[INDEX_JPG]),
             :png => boolean_convert(array[INDEX_PNG]), :flash => boolean_convert(array[INDEX_FLASH]), :flash_version => flash_version,
             :ssl => boolean_convert(array[INDEX_SSL]), :css => boolean_convert(array[INDEX_CSS]), :gps => boolean_convert(array[INDEX_GPS]) }
  
    case array[INDEX_CARRIER]
      when "DoCoMo"   ; docomo[device_id] = info 
      when "au"       ; au[device_id] = info 
      when "SoftBank" ; softbank[device_id] = info 
      when "EMOBILE"  ; emobile[device_id] = info 
    end
  end
end

# 書き出し
open("lib/jpmobile/mobile/z_device_info_docomo.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Docomo::DEVICE_INFO = "
  f.puts docomo.pretty_inspect
end

open("lib/jpmobile/mobile/z_device_info_au.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Au::DEVICE_INFO = "
  f.puts au.pretty_inspect
end

open("lib/jpmobile/mobile/z_device_info_softbank.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Softbank::DEVICE_INFO = "
  f.puts softbank.pretty_inspect
end

open("lib/jpmobile/mobile/z_device_info_emobile.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Emobile::DEVICE_INFO = "
  f.puts emobile.pretty_inspect
end
