#
# メールマガジン管理
#  配送対象ユーザを検索し配達(delivery)テーブルに登録する
#  10万ユーザ登録などの場合でも問題ないようにbackgroundで処理する
#
module MlgAddTargetUsersWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :mlg_add_target_users_worker
      end
    end
  end
  
  def regist_delivery(rp = {})
    mlg_magazine_id = rp[:mlg_magazine_id]
    
    insert_field = ['base_user_id', 'mlg_magazine_id']
    
    # ID の範囲を指定して順次送る（ユーザー数が増えても負荷が増えないための方策）
    first = BaseUser.minimum('id')
    last = BaseUser.maximum('id')
    limit = AppResources['mlg']['add_target_users_size'] # 一回の範囲の長さ
    from = first
    to = from
    while true # 一度に処理データ全てを読み込まない
      to += limit - 1
      users = BaseUser.find_users_by_all_search_info(rp[:user_info], rp[:profile_info], rp[:point_info], 
                                  {:conditions => "base_users.id between #{from} and #{to}"}) 

      insert_data = Array.new
      users.each do |user|
        insert_data << [user.id, mlg_magazine_id]
      end

      MlgDelivery.import(insert_field, insert_data, :optimize=>true)
      
      break if to >= last
      from = to + 1
    end
    
  rescue Exception => e
    @logger.error "mlg add_user\n #{e}"
  end

end
