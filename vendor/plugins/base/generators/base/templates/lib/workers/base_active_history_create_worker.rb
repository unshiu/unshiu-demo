#
# アクティブユーザ数履歴計測処理
#
class BaseActiveHistoryCreateWorker < BackgrounDRb::MetaWorker
  include BaseActiveHistoryCreateWorkerModule
end