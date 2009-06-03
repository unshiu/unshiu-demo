# == Schema Information
#
# Table name: pnt_points
#
#  id            :integer(4)      not null, primary key
#  base_user_id  :integer(4)      not null
#  point         :integer(4)      default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :datetime
#  pnt_master_id :integer(4)      not null
#

module PntPointModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        # validation
        validates_presence_of :base_user_id, :pnt_master_id
        # only rails 2.0 validates_numericality_of :point, :greater_than_or_equal_to => 0
        validates_numericality_of :point

        # relation
        belongs_to :base_user, :with_deleted => true
        belongs_to :pnt_master
        has_many :pnt_histories
      end
    end
  end
  
  def validate
    errors.add(:point, "can't set minus point.") if self.point < 0
  end
  
  module ClassMethods
    # 初期化
    def base_create_new(pnt_master_id, base_user_id)
      base = PntPoint.new
      base.pnt_master_id = pnt_master_id
      base.base_user_id = base_user_id
      base.point = 0 # 初期状態は0ポイント
      return base
    end
  
    # ユーザがもっているポイント合計値を返す
    def base_user_all_point(base_user_id)
      sum('point', :conditions => [' base_user_id = ? ', base_user_id])
    end
  
    # ユーザのポイントを返す。
    # ポイントはポイント種別ID（pnt_master_id）をもちその２つのキーでユニークになる
    def find_base_user_point(pnt_master_id, base_user_id)
      find_with_deleted(:first, :conditions => [' pnt_master_id = ? and base_user_id = ? ', pnt_master_id, base_user_id])
    end
  
    # ポイントマスタID(pnt_master_id)とユーザID(base_user_id)で検索し、
    # あったらそのレコードをかえしなかったら新規作成する。
    # _param1_:: pnt_master_id ポイントマスタID
    # _param2_:: base_user_id  ユーザID
    # return  :: PntPoint
    def find_or_create_base_user_point(pnt_master_id, base_user_id)
      pnt_point = find_base_user_point(pnt_master_id, base_user_id)
      if pnt_point.nil?
        pnt_point = PntPoint.new
        pnt_point.pnt_master_id = pnt_master_id
        pnt_point.base_user_id = base_user_id
        pnt_point.point = 0 # point初期値は0
      end
      return pnt_point
    end
  
    # ユーザのポイントを返す。
    # 複数のポイントを保持していた場合すべてかえす
    def find_base_user_points(base_user_id)
      find(:all, :conditions => [' base_user_id = ? ', base_user_id])
    end
  end

end
