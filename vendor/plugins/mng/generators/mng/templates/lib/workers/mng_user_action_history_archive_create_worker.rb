#
# 管理者ログ生成処理
#
class MngUserActionHistoryArchiveCreateWorker < BackgrounDRb::MetaWorker
  include MngUserActionHistoryArchiveCreateWorkerModule
end
