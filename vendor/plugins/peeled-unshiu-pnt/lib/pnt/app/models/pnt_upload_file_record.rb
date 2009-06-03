#
#  pnt_master_id
#  base_user_id 
#  message
#  point   

require 'active_form'

module PntUploadFileRecordModule
  
  class << self
    def included(base)
      base.class_eval do
        attr_accessor :pnt_master_id, :base_user_id, :point, :message

        validates_presence_of     :pnt_master_id, :base_user_id, :point, :message
        validates_numericality_of :pnt_master_id, :base_user_id, :point
      end
    end
  end
  
  # 初期化する
  # csvから生成された配列がある場合はそれを設定する
  # 順番は固定仕様
  def initialize(arrays = nil)
    return self if arrays.nil?
    
    self.pnt_master_id = arrays[0]
    self.base_user_id = arrays[1]
    self.point = arrays[2]
    self.message = arrays[3]
    return self
  end
    
  # オブジェクトを文字列化する
  # return  :: string 内容を,(カンマ)区切りで出力
  def to_s
    "#{self.pnt_master_id},#{self.base_user_id},#{self.point},#{self.message}"
  end
  
end
  