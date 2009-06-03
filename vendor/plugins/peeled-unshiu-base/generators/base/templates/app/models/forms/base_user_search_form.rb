#
# 管理画面でのユーザ検索用form
#
module Forms
  class BaseUserSearchForm < ActiveForm
    include Forms::BaseUserSearchFormModule
  end
end