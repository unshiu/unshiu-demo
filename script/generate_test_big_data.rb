#!/usr/bin/env ruby

#
# テスト用データを生成する
#　起動例）　ruby script/generate_test_data

$KCODE = 'u'
require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'application'
require 'fastercsv'
require 'pp'

#　設定値
users         = 100  # ユーザ数
friends_users = 100  # 友達の最大数

dia_entries   = 100  # 日記エントリー最大数
dia_comment   = 10   # 日記コメント最大数

abm_images    = 100 # アルバム最大画像数
abm_comment   = 10  # アルバム画像コメント最大数

communities              = 1000   # コミュニティ数
community_users          = 10     # コミュニティに所属する最大人数
community_topices        = 1000   # トピック数
community_topic_comments = 10     # トピックのコメント最大数

tables = ["base_users", "base_profiles", "base_friends", "dia_diaries", "dia_entries", "dia_entry_comments",
          "abm_albums", "abm_images", "abm_image_comments", "cmm_communities", "cmm_communities_base_users",
          "tpc_topics", "tpc_topic_cmm_communities", "tpc_comments"]

# ユーザ生成
FasterCSV.open("#{RAILS_ROOT}/tmp/base_users.csv", "w") do |csv|
  for i in 2..users
    s = sprintf("%.6d", i).to_s
    email = "#{s}@test.unshiu.jp"
    csv << [i,email,email,"00742970dc9e6319f8019fd54864d3ea740f04b1", "7e3041ebc2fc05a40c60028e2c4901a81035d3cd", 
            Time.now, Time.now, nil,nil,nil, 2, nil, "uid_for_test", Time.now, nil, nil,
            false, false, 2, true, nil, nil, email]
  end
end

# プロフィール生成
FasterCSV.open("#{RAILS_ROOT}/tmp/base_profiles.csv", "w") do |csv|
  for i in 1..users
    s = sprintf("%.6d", i).to_s
    csv << [i,i,"名前#{s}", UserRelationSystem::PUBLIC_LEVEL_ALL, nil, nil, "紹介文：#{s}", UserRelationSystem::PUBLIC_LEVEL_ALL,
            rand(1), UserRelationSystem::PUBLIC_LEVEL_ALL, rand(2), UserRelationSystem::PUBLIC_LEVEL_ALL,
            Date.today, UserRelationSystem::PUBLIC_LEVEL_ALL, Time.now, Time.now, nil, nil, rand(47), UserRelationSystem::PUBLIC_LEVEL_ALL]
  end
end

# 友達関係
FasterCSV.open("#{RAILS_ROOT}/tmp/base_friends.csv", "w") do |csv|
  for i in 1..users
    while true # 自分自身と友達にはなれないので
      friend_id = rand(users)
      break if friend_id != i
    end
  
    for j in 1..rand(friends_users) 
      csv << [nil,i,friend_id, 1, Time.now,Time.now, nil]
      csv << [nil,friend_id,i, 1, Time.now,Time.now, nil]
    
      friend_id = friend_id + 1
      break if friend_id > users || friend_id == i
    end
  end
end

# 日記生成
FasterCSV.open("#{RAILS_ROOT}/tmp/dia_diaries.csv", "w") do |d_csv|
  for i in 1..users
    s = sprintf("%.6d", i).to_s
    d_csv << [nil, i, 1, Time.now, Time.now, nil]
    
    # 記事
    FasterCSV.open("#{RAILS_ROOT}/tmp/dia_entries.csv", "a") do |e_csv|
      for j in 1..rand(dia_entries) 
        e_csv << [nil,i,"entry:#{s}:#{j}", "本文\nentry:#{s}:#{j}", rand(4), false, Time.now, Time.now, nil, Time.now, Time.now - rand(365).day]
      end
    end
    
    # コメント
    FasterCSV.open("#{RAILS_ROOT}/tmp/dia_entry_comments.csv", "a") do |c_csv|
      for k in 1..rand(dia_comment) 
        c_csv << [nil,rand(users), rand(dia_entries), "本文\ncomment:#{s}:#{k}", Time.now, Time.now, nil, nil, true]
      end
    end
    
  end
end

# アルバム生成
FasterCSV.open("#{RAILS_ROOT}/tmp/abm_albums.csv", "w") do |a_csv|
  for i in 1..users
    s = sprintf("%.6d", i).to_s
    a_csv << [nil, i, "アルバムタイトル:#{s}", "本文\nアルバム#{s}#{i}", Time.now, Time.now, nil, rand(5)]
  
    # 画像
    FasterCSV.open("#{RAILS_ROOT}/tmp/abm_images.csv", "a") do |i_csv|
      for j in 1..rand(abm_images)
        i_csv << [nil, i, "image title:#{s}:#{i}", "image body:#{s}:#{i}", Time.now, Time.now, nil, File::open('public/images/default/logo.gif')]
      end
    end
  
    # コメント
    FasterCSV.open("#{RAILS_ROOT}/tmp/abm_image_comments.csv", "a") do |c_csv|
      for k in 1..rand(abm_comment) 
        c_csv << [nil, rand(users), rand(abm_images), "本文\ncomment:#{s}:#{k}", Time.now, Time.now, nil, nil]
      end
    end
  end
end

# コミュニティ生成
FasterCSV.open("#{RAILS_ROOT}/tmp/cmm_communities.csv", "w") do |csv|
  for i in 1..communities
    s = sprintf("%.6d", i).to_s
    csv << [nil, "コミュニティ:#{s}", "コミュニティプロフィール:#{s}", nil, CmmCommunity::JOIN_TYPE_FREE, Time.now, Time.now, 
              CmmCommunitiesBaseUser::STATUS_MEMBER, nil]
  end
end

# メンバー
FasterCSV.open("#{RAILS_ROOT}/tmp/cmm_communities_base_users.csv", "w") do |csv|
  # 管理者
  for i in 1..communities
    s = sprintf("%.6d", i).to_s
    csv << [nil, i, rand(users), Time.now, Time.now, nil, CmmCommunitiesBaseUser::STATUS_ADMIN]
    
    # 一般メンバー
    for j in 1..rand(community_users)
      csv << [nil, i, rand(users), Time.now, Time.now, nil, CmmCommunitiesBaseUser::STATUS_MEMBER]
    end
  end
end

# トピック
FasterCSV.open("#{RAILS_ROOT}/tmp/tpc_topics.csv", "w") do |csv|
  for i in 1..rand(community_topices)
    s = sprintf("%.6d", i).to_s
    csv << [nil, "トピック:#{s}:#{i}", "トピック本文\n#{s}:#{i}", rand(users), Time.now, Time.now, nil, Time.now]
  end
end

FasterCSV.open("#{RAILS_ROOT}/tmp/tpc_topic_cmm_communities.csv", "w") do |csv|
  for i in 1..rand(community_topices)
    s = sprintf("%.6d", i).to_s
    csv << [nil, i, rand(communities), TpcRelationSystem::PUBLIC_LEVEL_ALL, Time.now, Time.now, nil]
    
    # コメント
    FasterCSV.open("#{RAILS_ROOT}/tmp/tpc_comments.csv", "a") do |c_csv|
      for j in 1..rand(community_topic_comments)
        c_csv = [nil, "トピックコメント\n#{s}:#{i}:#{j}", "トピックコメント本文\n#{s}:#{i}:#{j}", i, rand(users), Time.now, Time.now, nil]
      end
    end
  end
end

tables.each do |table_name|
  BaseUser.connection.execute("alter table #{table_name} auto_increment = 0;")
  BaseUser.connection.execute("delete from #{table_name};")
  BaseUser.connection.execute("load data infile '#{RAILS_ROOT}/tmp/#{table_name}.csv' into table #{table_name} fields terminated by ',';")
  pp "load #{table_name} finish"
end
