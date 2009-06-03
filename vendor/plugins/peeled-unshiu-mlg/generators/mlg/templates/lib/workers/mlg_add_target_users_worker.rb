#
# メールマガジン管理
#  配送対象ユーザを検索し配達(delivery)テーブルに登録する
#  10万ユーザ登録などの場合でも問題ないようにbackgroundで処理する
#
class MlgAddTargetUsersWorker < BackgrounDRb::MetaWorker
  include MlgAddTargetUsersWorkerModule
end
