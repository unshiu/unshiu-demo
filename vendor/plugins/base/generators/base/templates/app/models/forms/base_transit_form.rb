#
# ユーザ推移用ActiveForm
#
module Forms
  class BaseTransitForm < ActiveForm
    include Forms::BaseTransitFormModule
  end
end