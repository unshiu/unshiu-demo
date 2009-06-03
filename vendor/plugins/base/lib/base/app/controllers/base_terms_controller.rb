#
# 利用規約表示
#  パラメータは単純にひきづりまわす。会員登録画面以外から呼ばれるようなことを考慮しなければならなくなったらsessionを検討する
module BaseTermsControllerModule
  class << self
    def included(base)
      base.class_eval do
        nested_layout_with_done_layout
      end
    end
  end
end