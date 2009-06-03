#!/usr/bin/env ruby

#
# 月別の取引履歴情報を生成する。
#　起動例）　ruby pnt_history_summary_generate 2001-01-01 2001-01-31
#
# 開始、終了日付を省略した場合起動時の月を処理範囲とする
# 生成ファイルは 作成時間+ランダムな英数字
#
require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'application'
require 'fastercsv'

$KCODE = 'u'

EXPORT_PATH = RAILS_ROOT + "/" + AppResources['pnt']['history_file_path'] + "/"

def export_csv(start_at, end_at)
  file_name = Time.now.strftime("%Y%m%d%H%M%S") + Util.random_string(10)
  histories = PntHistory.find_by_period_histories(start_at, end_at)
  output_file = FasterCSV.open(EXPORT_PATH + file_name, "w") do |csv|
    unless histories.nil?
      histories.each do |history|
        csv << ["#{history.pnt_point.pnt_master.title}",
                "#{history.pnt_point.base_user.login}",
                "#{history.pnt_point.base_user.email}",
                "#{history.difference}",
                "#{history.message}",
                "#{history.created_at.strftime("%Y/%m/%d %H:%M:%S")}",
                "#{history.updated_at.strftime("%Y/%m/%d %H:%M:%S")}"]
      end
    end
  end
  return file_name
end

if ARGV.size == 2 then
  begin
    start_at = Time.parse(ARGV[0])
    start_at = Time.mktime(start_at.year, start_at.month, start_at.day, 0, 0, 0)
    end_at = Time.parse(ARGV[1])
    end_at = Time.mktime(end_at.year, end_at.month, end_at.day, 23, 59, 59)
    type = PntHistorySummary::KIND_TYPE_FREE
  rescue ArgumentError => e
    p "usage: ruby script/pnt_history_summary_generate 2001-01-01 2001-01-31"
    exit 1
  end
else
  start_at = Time.now.beginning_of_month
  end_at = Time.now.next_month.beginning_of_month - 1
  type = PntHistorySummary::KIND_TYPE_MONTH
end

summary = PntHistorySummary.find_by_period_summary(start_at, end_at)
if summary.nil?
  summary = PntHistorySummary.new
  summary.kind_type = type
  summary.start_at = start_at
  summary.end_at = end_at
  summary.sum_issue_point = PntHistory.sum_issue_point(start_at, end_at)
  summary.sum_use_point = PntHistory.sum_use_point(start_at, end_at)
  summary.record_count  = PntHistory.count_record_count(start_at, end_at)
  summary.file_name = export_csv(start_at, end_at)
  
  if summary.save
    p "pnt_history_summary created. from : #{start_at} to #{end_at}" 
  else
    p "can't create pnt_history_summary: #{start_at} to #{end_at}" 
  end
else
  p "pnt_history_summary already created: #{start_at} to #{end_at}" 
end

