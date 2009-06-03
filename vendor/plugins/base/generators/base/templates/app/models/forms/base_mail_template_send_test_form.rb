#
# メールテスト送信form
#
module Forms
  class BaseMailTemplateSendTestForm < ActiveForm
    include Forms::BaseMailTemplateSendTestFormModule
  end
end