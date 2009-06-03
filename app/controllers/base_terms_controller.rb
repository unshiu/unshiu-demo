#
# 利用規約表示
#  パラメータは単純にひきづりまわす。会員登録画面以外から呼ばれるようなことを考慮しなければならなくなったらsessionを検討する
class BaseTermsController < ApplicationController
  include BaseTermsControllerModule
end