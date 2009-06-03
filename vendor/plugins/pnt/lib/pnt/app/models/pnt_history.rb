# == Schema Information
#
# Table name: pnt_histories
#
#  id            :integer(4)      not null, primary key
#  pnt_point_id  :integer(4)      not null
#  difference    :integer(4)      default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :datetime
#  message       :string(2000)    default(""), not null
#  pnt_filter_id :integer(4)
#  amount        :integer(4)      default(0)
#

module PntHistoryModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :pnt_point, :with_deleted => true

        validates_presence_of :message
        validates_numericality_of :difference, :amount
      end
    end
  end
  
  module ClassMethods
    
    # 指定ポイントの履歴を追加順に返す
    # _param1_:: pnt_point_id ポイントID
    # return  :: 指定ポイントのの履歴
    def find_by_point_histories(pnt_point_id)
      find(:all, :conditions => [' pnt_point_id = ? ', pnt_point_id], :order => 'updated_at desc ')
    end
  
    # ページ管理をして指定ポイントの履歴を追加順に返す
    # _param1_:: pnt_point_id ポイントID
    # _param2_:: size         取得最大数
    # _param2_:: page         現在のページ数
    # return  :: 指定ポイントのの履歴
    def find_by_point_histories_with_pagenate(pnt_point_id, size, page)
      find(:all, :conditions => [' pnt_point_id = ? ', pnt_point_id], 
                 :page => { :size => size, :current => page }, 
                 :order => 'updated_at desc ')
    end
  
    # 対象期間内の履歴をかえす
    # 期間を省略して全履歴を取得できるのは危険なのでなし
    # _param1_:: start_at 対象開始日。省略不可
    # _param2_:: end_at   象終了日。省略不可
    # return  :: 対象期間内の履歴
    def find_by_period_histories(start_at, end_at)
      find(:all, :conditions => [' updated_at >= ? and updated_at <= ? ', start_at, end_at])
    end
  
    # 発行総ポイントを返す
    # _param1_:: start_at 集計処理対象開始日。省略時は範囲を指定しない
    # _param2_:: end_at   集計処理対象終了日。省略時は範囲を指定しない
    # return  :: 集計発行ポイント
    def sum_issue_point(start_at = nil, end_at = nil)
      if start_at.nil? or end_at.nil?
        sum_issue_point = sum('difference', :conditions=>['difference > 0'])
      else
        sum_issue_point = sum('difference', :conditions=>['difference > 0 and updated_at >= ? and updated_at <= ? ', start_at, end_at])
      end
      sum_issue_point.nil? ? 0 : sum_issue_point
    end
  
    # 総利用ポイントを返す
    # _param1_:: start_at 集計処理対象開始日。省略時は範囲を指定しない
    # _param2_:: end_at   集計処理対象終了日。省略時は範囲を指定しない
    # return  :: 総利用ポイント
    def sum_use_point(start_at = nil, end_at = nil)
      if start_at.nil? or end_at.nil?
        sum_use_point = sum('difference', :conditions=>['difference < 0'])
      else
        sum_use_point = sum('difference', :conditions=>['difference < 0 and updated_at >= ? and updated_at <= ? ', start_at, end_at])
      end
      sum_use_point.nil? ? 0 : sum_use_point * -1
    end
  
    # 対象レコード件数を返す
    # _param1_:: start_at 集計処理対象開始日。省略時は範囲を指定しない
    # _param2_:: end_at   集計処理対象終了日。省略時は範囲を指定しない
    # return  :: 対象レコード件数
    def count_record_count(start_at = nil, end_at = nil)
      if start_at.nil? or end_at.nil?
        count
      else
        count(:conditions=>['updated_at >= ? and updated_at <= ? ', start_at, end_at])
      end
    end
  end
end
