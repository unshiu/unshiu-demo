#!/usr/bin/ruby -Ku
# impress から機種名を取得するスクリプト。

require 'rubygems'
require 'kconv'
require 'open-uri'
require 'fastercsv'
require 'pp'

class Module
  def enum args, b = nil
    val = -1
    args.split(/,/).each{|c|
      c = c.strip
      break if c.size == 0
      if /(\S+)\s*=\s*(.+)/ =~ c
        const_set($1, val = eval($2, b))
      else
        const_set(c.strip, val+=1)
      end
    }
  end
end

module Impress
  
  class UserAgent
    attr_accessor :filename
    attr_accessor :docomo, :au, :softbank, :willcom
  
    enum %q{ 
        CARRIER, MODEL_NAME, DEVICE_NAME, USER_AGENT, USER_AGENT_SCRAP, UPDATED_AT
      }, binding
  
    def initialize(filepath)
      self.filename = Dir::glob(filepath + "UserAgent*").first
      self.docomo = {}
      self.au = {}
      self.softbank = {}
      self.willcom = {}
    end
  
    def parse
      arryas = FasterCSV.parse(open(filename).read.toutf8)
    
      arryas.each_with_index do |array, index|
        next if index < 2
        
        device_id = array[MODEL_NAME]
        
        info = { :device => array[DEVICE_NAME] }
        
        case array[CARRIER]
          when "DoCoMo"       ; self.docomo[device_id] = info 
          when "au", "Tu-Ka"  ; self.au[device_id] = info
          when "SoftBank" ; self.softbank[device_id] = info 
          when "WILLCOM"  ; self.willcom[device_id] = info
        end
      end
    end
    
  end
  
  class ProfileData
    attr_accessor :filename
    attr_accessor :docomo, :au, :softbank, :willcom
  
    enum %q{ 
        CARRIER, MODEL_NAME, MFR, NICKNAME, RELEASE_DATE, SERIES, MARKUP_LANGUAGE, BROWSING_VERSION, BAUD,
        COLORS, GIF, JPEG, PNG, BMP2, BMP4, MNG, TRANSMISSION, SSL, CAMERA_PIXEL, CAMERA_PIXEL_2, 
        APP, APP_KIND, APP_VERSION, APP_MAX_CONTENT, MEMORY_SLOT, CHORD, 
        RINGER_MELODY_SONG, RINGER_MELODY_FULL, RINGER_MELODY_MOVIE, QR, FELICA, BLUETOOTH, FLASH, 
        CA_VERISIGN, CA_ENTRUST, CA_CYBER_TRUST, CA_GEOTRUST, CA_RSA_SECURITY, QVGA, FULL_BROWSER, INFRARED,
        ATTACHED_FILE_VIEWER, GPS, MOVIE, FULL_BROWSER_VERSION, FULL_BROWSER_USER_AGENT, ATTACHED_SIZE,
        FLASH_VERSION, CACHE_MAX, ONE_SEGMENT, TV_PHONE, OFFICE_WEBDL, OFFICE_FILE_SIZE, COOKIE, UID,
        SUICA, MAIL_URL_MAX, BOOKMARKURL_MAX, BROWSER_URL_MAX, PUSH_TALK, MAIL_SUBJECT_MAX, 
        ANIMATION_GIF, TRANSMISSION_GIF, MAIL_ATTACHED_FILE_SIZE, HTML_MAIL, KISEKAE, UPDATED_AT
      }, binding
  
    def initialize(filepath)
      self.filename = Dir::glob(filepath + "ProfileData*").first
      self.docomo = {}
      self.au = {}
      self.softbank = {}
      self.willcom = {}
    end
  
    def boolean_convert(value)
      value == "Y" ? true : false
    end
  
    def parse
      arryas = FasterCSV.parse(open(self.filename).read.toutf8)
      
      arryas.each_with_index do |array, index|
        next if index < 2

        device_id = array[MODEL_NAME]
        flash_version = array[FLASH_VERSION] == "0" ? nil : array[FLASH_VERSION].delete("Flash Lite ")
        colors = array[COLORS].nil? ? nil : array[COLORS][/\d+/]
        
        name = array[MODEL_NAME]
        name = name + " #{array[NICKNAME]}" unless array[NICKNAME].nil?
      
        info = { :name => name, 
                 :gps => boolean_convert(array[GPS]),
                 :jpg => boolean_convert(array[JPEG]),
                 :gif => boolean_convert(array[GIF]), 
                 :png => boolean_convert(array[PNG]), 
                 :flash => boolean_convert(array[FLASH]), 
                 :flash_version => flash_version,
                 :ssl => boolean_convert(array[SSL]),
                 :colors => colors,
                 :chord => array[CHORD],
                 :ringer_melody_song => boolean_convert(array[RINGER_MELODY_SONG]),
                 :ringer_melody_song_full => boolean_convert(array[RINGER_MELODY_FULL]),
                 :ringer_melody_movie => boolean_convert(array[RINGER_MELODY_MOVIE]),
                 :qr => boolean_convert(array[QR]),
                 :bluetooth => boolean_convert(array[BLUETOOTH]),
                 :updated_at => array[UPDATED_AT]
        }

        case array[CARRIER]
          when "DoCoMo"       ; self.docomo[device_id] = info 
          when "au", "Tu-Ka"  ; self.au[device_id] = info
          when "SoftBank" ; self.softbank[device_id] = info 
          when "WILLCOM"  ; self.willcom[device_id] = info
        end

      end
    end
  end
end

USE_DB = false
OUTPUT_DIR = "/tmp/"

ARGV.each do |arg| 
 case
 when arg =~ /--url=/
   URL = arg.sub("--url=", "")
 when arg =~ /--username=/
   USERNAME = arg.sub("--username=", "")
 when arg =~ /--password=/
   PASSWORD = arg.sub("--password=", "")
 when arg =~ /--output-dir=/
   OUTPUT_DIR = arg.sub("--output-dir=", "")
 when arg =~ /--with-db/
   USE_DB = true
 end
end

file_name = URL.split("/").last
file_full_path = OUTPUT_DIR + file_name
unzip_output = OUTPUT_DIR + "profile/"

system("wget #{URL} --user=#{USERNAME} --password=#{PASSWORD} --directory-prefix=#{OUTPUT_DIR} --no-check-certificate")
system("unzip -o #{file_full_path} -d #{unzip_output} ")

user_agent_data = Impress::UserAgent.new(unzip_output)
user_agent_data.parse

profile_data = Impress::ProfileData.new(unzip_output)
profile_data.parse

docomo = {}
profile_data.docomo.each_pair do |key, value|
  device = user_agent_data.docomo[key][:device]
  value[:device] = device
  docomo[key] = value
end

au = {}
profile_data.au.each_pair do |key, value|
  device = user_agent_data.au[key][:device]
  value[:device] = device
  au[device] = value
end

softbank = {}
profile_data.softbank.each_pair do |key, value|
  device = user_agent_data.softbank[key][:device]
  value[:device] = device
  softbank[key] = value
end

willcom = {}
profile_data.willcom.each_pair do |key, value|
  device = user_agent_data.willcom[key][:device]
  value[:device] = device
  willcom[key] = value
end

if USE_DB
  require 'active_record'
  require File.join(File.dirname(__FILE__), '../lib/jpmobile')
  require File.join(File.dirname(__FILE__), '../lib/jpmobile/model/jpmobile_device')
  
  ENV['RAILS_ENV'] ||= 'development'
  
  database = YAML.load_file(File.join(File.dirname(__FILE__), '../config/database.yml'))
  ActiveRecord::Base.establish_connection(database[ENV['RAILS_ENV']]["jpmobile"])
  
  jpmobile_device = Jpmobile::Model::JpmobileDevice.save_from_hash(1, docomo)
  jpmobile_device = Jpmobile::Model::JpmobileDevice.save_from_hash(2, au)
  jpmobile_device = Jpmobile::Model::JpmobileDevice.save_from_hash(3, softbank)
  jpmobile_device = Jpmobile::Model::JpmobileDevice.save_from_hash(4, willcom)
  
else
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

  open("lib/jpmobile/mobile/z_device_info_willcom.rb","w") do |f|
    f.puts "Jpmobile::Mobile::Willcom::DEVICE_INFO = "
    f.puts willcom.pretty_inspect
  end
end

File.delete("#{file_full_path}")

