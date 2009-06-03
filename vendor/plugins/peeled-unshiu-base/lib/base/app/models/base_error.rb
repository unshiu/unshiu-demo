# == Schema Information
#
# Table name: base_errors
#
#  id         :integer(4)      not null, primary key
#  error_code :string(255)     not null
#  message    :text            default(""), not null
#  coping     :text            default(""), not null
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

module BaseErrorModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        validates_presence_of :error_code
        validates_presence_of :message
      end
    end
  end
  
  module ClassMethods
  
    # エラーコードからエラー情報を取得する。ただし存在しないエラーコードの場合、
    # 共通エラー情報を返す
    # _error_code_:: エラーコード
    def find_by_error_code_use_default(error_code)
      base_error = find_by_error_code(error_code)
      base_error.nil? ? BaseError.new({:error_code => "U-99999", :message => "致命的なエラーが発生しました。" }) : base_error
    end

  end
  
end
