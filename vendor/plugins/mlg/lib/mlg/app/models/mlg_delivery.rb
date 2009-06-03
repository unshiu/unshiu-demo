# == Schema Information
#
# Table name: mlg_deliveries
#
#  id              :integer(4)      not null, primary key
#  base_user_id    :integer(4)      not null
#  mlg_magazine_id :integer(4)      not null
#  sended_at       :datetime
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  deleted_at      :datetime
#

module MlgDeliveryModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        # -------------------------
        # relation
        # -------------------------
        belongs_to :base_user
        belongs_to :mlg_magazine

        # -------------------------
        # constant
        # -------------------------
        const_set('TARGET_LIMIT', AppResources["mlg"]["deliver_limit_size"])
      end
    end
  end
  
  module ClassMethods
    # 指定されたメールマガジンIDをまだおくっていないユーザを取得する
    # ただし取得数は制限する
    # _param1_:: mlg_magazine_id メールマガジンID
    # return  :: Array(BaseUser)
    def find_target_delivers(mlg_magazine_id)
      BaseUser.find(:all, :joins => "INNER JOIN mlg_deliveries ON base_users.id = mlg_deliveries.base_user_id", 
                    :select => 'base_users.*, mlg_deliveries.base_user_id, mlg_deliveries.id as mlg_delivery_id',
                    :conditions => [' mlg_deliveries.mlg_magazine_id = ? and mlg_deliveries.sended_at is null', mlg_magazine_id], 
                    :limit => MlgDelivery::TARGET_LIMIT, :order => 'mlg_deliveries.id')
    end
  
    # 指定されたメールマガジンIDの送信ユーザ数を取得する
    # _param1_:: mlg_magazine_id メールマガジンID
    # return  :: Integer
    def count_target_delivers(mlg_magazine_id)
      count(:all, :conditions => [' mlg_magazine_id = ? ', mlg_magazine_id])
    end
  
    # 配信処理済みとして更新する
    # find_target_deliversで取得したすぐユーザを更新する想定
    # その間に対象追加はない前提
    # _param1_:: mlg_magazine_id メールマガジンID
    def update_sended_target_delivers(mlg_magazine_id, last_id)
      sql = "update mlg_deliveries set sended_at = '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}'" +
            " where mlg_magazine_id = #{mlg_magazine_id} " +
            " and id <= #{last_id}" +
            " and sended_at is null" +
            " order by id"
      connection().execute(sanitize_sql(sql))
    end

    # 二重登録されているデータを削除し、削除数をかえす
    # _param1_:: mlg_magazine_id メールマガジンID
    # return  :: Integer 削除した数
    def double_send_delete(mlg_magazine_id)
      count = 0
      targets = find_by_sql(["select base_user_id, count(0)  from mlg_deliveries 
                            where mlg_magazine_id = ? 
                            group by base_user_id having count(0) > 1", mlg_magazine_id])
      targets.each do |target|
        mlg_deliveries = find(:all, :conditions => ['base_user_id = ? and mlg_magazine_id = ?', target.base_user_id, mlg_magazine_id])
        mlg_deliveries.each_with_index do |mlg_delivery, index| 
          if index+1 < mlg_deliveries.size # 1行を残し削除
            mlg_delivery.destroy 
            count = count + 1
          end
        end
      end
      return count
    end
  end
  
end
