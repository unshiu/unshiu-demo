#!/usr/bin/env ruby
#
# メール配信処理
# cronで定期起動する　複数サーバでの処理は想定していない
# 起動例）　ruby mlg_deliverer
#　
require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'application_controller'

# environmentで設定すると無条件でappと共通になるのでこっちで上書き
ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :domain => AppResources["mlg"]["smtp_settings_domain"],
    :address => AppResources["mlg"]["smtp_settings_address"], 
    :port => AppResources["mlg"]["smtp_settings_port"],
  }
  
ActionMailer::Base.raise_delivery_errors = true

$KCODE = 'u'

@@log = Logger.new("#{RAILS_ROOT}/log/mlg_deliverer.log")
@@log.level = Logger::DEBUG
@@log.info("[start] mlg deliverer : #{Time.now}")

lockfilename = "/tmp/mlg_deliverer.lock"

if File.exist?(lockfilename) # ロックが取得できない場合は終了
  @@log.info("-- mlg deliverer lock not get")
  exit
else
  @@log.info("-- mlg deliverer lock get")
  lockfile = File.open(lockfilename, "w")
end

begin
  magazines = MlgMagazine.find_process_target_delivery_magazines
  magazines.each do |magazine|
    @@log.info(" target magazine : #{magazine.id}")
    delete_count = MlgDelivery.double_send_delete(magazine.id)
    @@log.info(" delete double regist : #{delete_count}")
    while true
      delivers = MlgDelivery.find_target_delivers(magazine.id)
      break if delivers.empty? # 対象がいなくなったら終了
      delivers.each do |deliver|
        begin 
          MlgMailer.deliver_mail_magazine(deliver, magazine)
        rescue Exception => e # 何らかの理由で誰かが送信処理に失敗しても無視して続ける
          @@log.error("can't send mail user_id:#{deliver.id}, magazine_id:#{magazine.id} :: " + e)
        end
      end
      last_id = delivers.last.mlg_delivery_id
      MlgDelivery.update_sended_target_delivers(magazine.id, last_id)
    end
    magazine.sended_at = Time.now
    magazine.save!
  end
  
rescue Exception => e
  @@log.error(e)
ensure
  @@log.info("[end] mlg deliverer :#{Time.now}")
  lockfile.close
  File.delete(lockfilename)
end

