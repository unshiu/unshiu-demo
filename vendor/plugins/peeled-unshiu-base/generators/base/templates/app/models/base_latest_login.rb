#
# ユーザの最終ログイン履歴を取得する
#
require 'miyazakiresistance'

class BaseLatestLogin < MiyazakiResistance::Base
  include BaseLatestLoginModule
end
