#!/usr/bin/env ruby

#
# controllerファイルから
# pnt_filter_title: という定義を検索し、ポイントフィルタマスターとして保存します。
#　
require File.dirname(__FILE__) + '/../../config/boot'
require File.dirname(__FILE__) + '/../../config/environment'

$KCODE = 'u'

SERACHE_PAHT = "#{RAILS_ROOT}/app/controllers"
target_controller_files = Array.new

def search_target_file(dir_path, target_controller_files)
  Dir::open(dir_path) do |dir|
    dir.each do |file_name|
      next if file_name == "." or file_name ==".." or file_name == ".svn"
      if dir_path =~ /\/$/
        file_path = dir_path + file_name
      else
        file_path = dir_path + "/" + file_name
      end
      if FileTest.directory?(file_path)
        search_target_file(file_path, target_controller_files)
      else
        target_controller_files << file_path
      end
    end
  end
end

search_target_file(SERACHE_PAHT, target_controller_files)

target_controller_files.each do |controller_file|
  open(controller_file) do |file|
    while line = file.gets
      line =~ /# pnt_filter_title:\s*([\S]+)/
      next if $1.nil?
      
      filter_master = PntFilterMaster.new
      filter_master.title = $1
      
      controller_file.split('/').last =~ /([\w]+)_controller.rb/
      filter_master.controller_name = $1
      
      while line = file.gets
        line =~ /def\s+([\w|\?|-|_]+)/
        next if $1.nil?
        filter_master.action_name = $1
        filter_master.save
        break
      end
    end
  end
end