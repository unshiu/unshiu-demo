#
# ユーザ一覧ファイル生成
#  指定検索条件の一覧ファイルを生成する
#  10万ユーザ登録などの場合でも問題ないようにbackgroundで処理する
#　　フォーマットの変更をしたい場合は、適時　csv_headerやrecordメソッドをoverwriteする
#
class BaseUserFileGenerateWorker < BackgrounDRb::MetaWorker
  include BaseUserFileGenerateWorkerModule
end
