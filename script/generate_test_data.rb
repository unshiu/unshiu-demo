#!/usr/bin/env ruby
#
# テスト用データを生成する
# なお大きなデータを生成する場合は　generate_test_big_data を利用する
#　起動例）　ruby script/generate_test_data

$KCODE = 'u'
require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'application'
require 'pp'

#　設定値
users         = 10000  # ユーザ数
friends_users = 10     # 友達の最大数

dia_entries   = 100  # 日記エントリー最大数
dia_comment   = 10   # 日記コメント最大数

abm_images    = 100 # アルバム最大画像数
abm_comment   = 10  # アルバム画像コメント最大数

communities              = 1000   # コミュニティ数
community_users          = 10     # コミュニティに所属する最大人数
community_topices        = 1000   # トピック数
community_topic_comments = 10     # トピックのコメント最大数

for i in 1..users
  s = sprintf("%.6d", i).to_s
  email = "#{s}@test.unshiu.jp"
  joined_at = Time.now + rand(60*60*24*30)
  
  quitted_at = nil
  status = 2
  if rand(10) == 1 
    quitted_at = Time.now + rand(60*60*24*30) 
    status = 4
  end
  
  user = BaseUser.new({:login => email, :email => email, :password => 'test',
                       :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :status => status, :joined_at => joined_at,
                       :quitted_at => quitted_at, :base_carrier_id => rand(4), :name => email})
                       
  user.make_activation_code                     
  user.save!
  
  name = "名前#{s}"
  public_all = UserRelationSystem::PUBLIC_LEVEL_ALL
  birthday = Time.now - 80.years + rand(60*60*24*365*80)
  
  profile = BaseProfile.new(:base_user_id => user.id,
                            :name => name, :name_public_level => public_all, 
                            :introduction => "#{name}", :introduction_public_level => public_all,
                            :sex => rand(2), :sex_public_level => public_all,
                            :civil_status => rand(2), :civil_status_public_level => public_all,
                            :birthday => birthday, :birthday_public_level => public_all,
                            :area => rand(47), :area_public_level => public_all)

  profile.save!
end
