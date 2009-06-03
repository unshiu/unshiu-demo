#
# ユーザの最終ログイン履歴を取得する
#
module BaseLatestLoginModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        if AppResources[:init][:tokyotyrant_on]
          server_config Rails.env, "config/miyazakiresistance.yml"
          set_timeout AppResources[:init][:tokyotyrant_timeout]
          set_column :app_name,     :string
          set_column :base_user_id, :integer
          set_column :latest_login, :integer
        end
        
        const_set('APP_NAME', "unshiu")
      end
    end
  end
  
  module ClassMethods
    
    # 最終ログイン履歴を更新する
    # _param1_:: base_user_id
    # return:: MixiLatestLogin　最終ログイン履歴
    def update_latest_login(base_user_id)
      return nil unless AppResources[:init][:tokyotyrant_on] 

      latest = find_by_base_user_id(base_user_id)
      if latest.nil?
        latest = create(:app_name => BaseLatestLogin::APP_NAME, :base_user_id => base_user_id, :latest_login => Time.now.to_i)
      else
        latest.latest_login = Time.now.to_i
        latest.save
      end
      latest
    end
    
    # ユーザIDから最終ログイン履歴を取得する。ログイン履歴がなければnilを返す
    # _param1_:: base_user_id
    # return:: BaseLatestLogin　最終ログイン履歴
    def find_by_base_user_id(base_user_id)
      return nil unless AppResources[:init][:tokyotyrant_on] 
      
      find(:first, :conditions => ["base_user_id = ?", base_user_id])
    end
  end
  
end
