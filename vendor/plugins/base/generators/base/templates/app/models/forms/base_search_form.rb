#
# PCでのユーザ検索用form
#
module Forms
  class BaseSearchForm < ActiveForm
    include Forms::BaseSearchFormModule
  end
end