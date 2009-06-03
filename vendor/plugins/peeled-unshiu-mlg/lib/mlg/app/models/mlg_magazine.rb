# == Schema Information
#
# Table name: mlg_magazines
#
#  id         :integer(4)      not null, primary key
#  title      :string(500)     default(""), not null
#  body       :string(2000)    default(""), not null
#  send_at    :datetime
#  sended_at  :datetime
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  deleted_at :datetime
#

module MlgMagazineModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        # -------------------------
        # relation
        # -------------------------
        has_many :mlg_deliveries

        validates_presence_of :title, :body
      end
    end
  end
  
  # 送信日の設定がされているかどうかを返す。
  # 仕様上nilの場合は設定されてない
  # return  :: 送信設定がされていればtrue,されていなければfalseがかえる
  def send_setup?
    self.send_at.nil? ? false : true
  end
  
  # 削除可能かどうかを返す。配信設定されていないか、配信時刻前なら削除可能
  def deletable?
    if send_at.nil?
      true
    elsif send_at > Time.now;
      true
    else
      false
    end
  end
  
  def send_count
    MlgDelivery.count_target_delivers(self.id)
  end  
  
  module ClassMethods
    # 送信処理対象のメールマガジンをかえす。
    # 送信日が既にすぎており、かつまだ送信されてないものが対象
    # return  :: MlgMagazine
    def find_process_target_delivery_magazines
      find(:all, :conditions => [' send_at <= ? and sended_at is null ', Time.now])
    end
  end
end
