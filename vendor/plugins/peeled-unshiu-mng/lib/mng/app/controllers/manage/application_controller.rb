require 'pp'

module ManageApplicationControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :manager_login_required
        
        layout 'mng_application'
      end
    end
  end
  
private

  # date_select などから存在しない日付が入力された場合にエラーにする
  # _record_:: 対象のレコード
  # _record_params_:: 対象のレコードを作ったもとの Hash
  # _attr_name_:: 対象の日付フィールド（カラム）
  # FIXED プラグイン validates_date_time を使う
  def validate_date(record, record_params, attr_name)
    begin
      Date.new(record_params[attr_name + '(1i)'].to_i,
               record_params[attr_name + '(2i)'].to_i,
               record_params[attr_name + '(3i)'].to_i)
    rescue ArgumentError
      record.errors.add(attr_name, '%{fn}が存在しない日付です。存在する日付に変更されました。') if record
      # record.send(attr_name + '=', nil)
      return false
    end
    return true
  end
  
  def manager_login_required
    if login_required
      if BaseUserRole.manager?(current_base_user)
        mng_user_action_history = MngUserActionHistory.new
        mng_user_action_history.base_user_id = current_base_user.id
        mng_user_action_history.user_action = params.pretty_inspect
        mng_user_action_history.save
        
        true
      else
        flash[:error] = t('view.flash.error.mange_application_manager_login_required')
        redirect_to :controller => "/base"
        return
      end
    else
      false
    end
  end
  
end
