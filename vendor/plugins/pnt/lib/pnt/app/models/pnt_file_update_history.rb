# == Schema Information
#
# Table name: pnt_file_update_histories
#
#  id            :integer(4)      not null, primary key
#  file_name     :string(256)     default(""), not null
#  record_count  :integer(4)
#  success_count :integer(4)
#  fail_count    :integer(4)
#  complated_at  :datetime
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  deleted_at    :datetime
#

module PntFileUpdateHistoryModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
      end
    end
  end
   
  # 既に更新処理が完了しているかどうかをかえす。
  # 終了していたら true, そうでなければfalseをかえす
  # return  :: 更新が成功したか
  def complated?
    self.complated_at.nil? ? false : true 
  end
  
end
