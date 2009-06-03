# 
# ポイント管理：ファイルによる一括更新処理
#
class PntImportWorker < BackgrounDRb::MetaWorker
  include PntImportWorkerModule
end