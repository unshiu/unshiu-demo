#
# ユーザ検索関連を集めたmodule
# TODO もっとエレガントにやる方法募集中
#
module BaseUserSearch 
  
  # ユーザを検索するSQLをかえす
  # _param1_:: user_info ユーザ情報 key = カラム, value = 検索値
  # _param1_:: profile_info プロフィール情報 key = カラム, value = 検索値
  # _param1_:: point_info ポイント情報 key = カラム, value = 検索値
  # _param1_:: campaign_info バンプ用キャンペーン情報 key = カラム, value = 検索値
  # _return_:: 検索SQL
  def self.create_condition_sql(user_info = {}, profile_info = {}, point_info = {})
    sql = Array.new
    sql << self.helper_create_sql_users_by_user_info(user_info) unless user_info.blank?
    sql << self.helper_create_sql_users_by_profile_info(profile_info) unless profile_info.blank?
    sql << self.helper_create_sql_users_by_point_info(point_info) unless point_info.blank?
    return sql.join(' and ')
  end
  
  private
    # ユーザ情報を検索するSQLをかえす
    # _param1_:: user_info ユーザ情報 key = カラム, value = 検索値
    # _return_:: 検索SQL
    def self.helper_create_sql_users_by_user_info(user_info = {})
      condition_sql = ""
      index = 0
      copy_user_info = user_info.clone # delete処理で元の情報が失われないように
      
      unless copy_user_info[:joined_at_start].nil?
        condition_sql << " ( base_users.joined_at >= '#{copy_user_info[:joined_at_start]}' ) "
        copy_user_info.delete(:joined_at_start)
        condition_sql << " and " if copy_user_info.keys.size >= 1
      end
      
      unless user_info[:joined_at_end].nil?
         end_date = Date.parse(copy_user_info[:joined_at_end])
         end_date += 1 # +1 しないと end_date が含まれなくなるので補正
         condition_sql << " ( base_users.joined_at < '#{end_date.strftime('%Y-%m-%d')}' ) " # こっちで <= にすると、翌日の 0:00:00 の入会者が含まれてしまいます 
         copy_user_info.delete(:joined_at_end)
         condition_sql << " and " if copy_user_info.keys.size >= 1
      end      
      
      copy_user_info.each_pair do | key, values |
        condition_sql << "("
        values.each_with_index do | value, vindex |
          value = "'#{value}'" if value != true && value != false
          condition_sql << " ( base_users.#{key} = #{value} ) "
          condition_sql << " or " if vindex+1 != values.size
        end
        condition_sql << ")"
        condition_sql << " and " if index+1 != copy_user_info.keys.size
        index += 1
      end
      return condition_sql
    end
   
    # プロフィール情報を検索するSQLをかえす
    # 年齢は ○才から×才までの場合　○才 < x才　前提なので日付変換した際の不等号が通常とは逆になる
    # _param1_:: profile_info プロフィール情報 key = カラム, value = 検索値
    # _return_:: 検索SQL      
    def self.helper_create_sql_users_by_profile_info(profile_info = {})
      condition_sql = ""
      index = 0
      copy_profile_info = profile_info.clone # delete処理で元の情報が失われないように
      
      unless copy_profile_info[:age_start].nil?
        birthday_start = Date.today << ((copy_profile_info[:age_start]) * 12)
        condition_sql << " ( base_profiles.birthday <= '#{birthday_start.strftime('%Y-%m-%d')}' ) "
        copy_profile_info.delete(:age_start)
        condition_sql << " and " if copy_profile_info.keys.size >= 1
      end
      
      unless copy_profile_info[:age_end].nil?
        birthday_end = (Date.today + 1) << ((copy_profile_info[:age_end] + 1) * 12) # 20歳以下の人は、21年前(20 + 1 年前)の明日以降生まれた人
        condition_sql << " ( base_profiles.birthday >= '#{birthday_end.strftime('%Y-%m-%d')}' ) "
        copy_profile_info.delete(:age_end)
        condition_sql << " and " if copy_profile_info.keys.size >= 1
      end
      
      unless copy_profile_info[:name].nil?
        name = copy_profile_info[:name].gsub('\'', '')
        condition_sql << " ( base_profiles.name like '%#{name}%' ) "
        copy_profile_info.delete(:name)
        condition_sql << " and " if copy_profile_info.keys.size >= 1
      end
      
      copy_profile_info.each_pair do | key, values |
        condition_sql << "("
        values.each_with_index do | value, vindex |
          value = "'#{value}'" if value != true && value != false
          condition_sql << " ( base_profiles.#{key} = #{value} ) "
          condition_sql << " or " if vindex+1 != values.size
        end
        condition_sql << ")"
        condition_sql << " and " if index+1 != copy_profile_info.keys.size
        index += 1
      end
      return condition_sql
    end
   
    # ポイント情報を検索するSQLをかえす
    # _param1_:: point_info ポイント情報 key = カラム, value = 検索値
    # _return_:: 検索SQL   
    def self.helper_create_sql_users_by_point_info(point_info = {})
      condition_sql = ""
      unless point_info[:pnt_master_id].blank?
        condition_sql << self.helper_create_sql_users_by_pnt_master_id(point_info[:pnt_master_id])

        unless point_info[:start_point].blank?
          condition_sql << " and "
          condition_sql << self.helper_create_sql_users_by_start_point(point_info[:start_point])
        end

        unless point_info[:end_point].blank?
          condition_sql << " and "
          condition_sql << self.helper_create_sql_users_by_end_point(point_info[:end_point])
        end
      end
      return condition_sql
    end
   
    # ポイントマスターIDを指定するSQLをかえす
    # _param1_:: pnt_master_id ポイントマスターID
    # _return_:: 検索SQL
    def self.helper_create_sql_users_by_pnt_master_id(pnt_master_id)
      condition_sql = ""
      condition_sql << " ( pnt_master_id = #{pnt_master_id} ) "
      return condition_sql
    end
      
    # ポイント下限からユーザを検索するSQLをかえす
    # _param1_:: start_point 保持ポイント下限
    # _return_:: 検索SQL
    def self.helper_create_sql_users_by_start_point(start_point)
      condition_sql = ""
      condition_sql << " ( pnt_points.point >= #{start_point} ) "
      return condition_sql
    end
   
    # ポイント上限からユーザを検索するSQLをかえす
    # _param1_:: end_point 保持ポイント上限
    # _return_:: 検索SQL   
    def self.helper_create_sql_users_by_end_point(end_point)
      condition_sql = ""
      condition_sql << " ( pnt_points.point <= #{end_point} ) " 
      return condition_sql
    end
end