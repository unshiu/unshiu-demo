# == Schema Information
#
# Table name: base_user_roles
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)
#  role         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

module BaseUserRoleModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        const_set('ROLE_KIND', ['manager'])
      end
    end
  end
  
  module ClassMethods
    
    BaseUserRole::ROLE_KIND.each do |role|
      
      # FIXME そもそも　？　なのに戻り値が　オブジェクトというのがおかしい
      # ex) def manager?(base_user)
      define_method("#{role}?") do |base_user|
        find_by_base_user_id_and_role(base_user.id, role)
      end
      
      # 指定ユーザのIDに権限を付与する
      # _param1_:: base_user_id
      define_method("add_#{role}") do |base_user_id|
        base_user_role = find_by_base_user_id(base_user_id)
        return nil if base_user_role

        base_user_role = BaseUserRole.new({:base_user_id => base_user_id, :role => role})
        base_user_role.save
      end
      
      # 指定ユーザのIDに権限を削除する
      # _param1_:: base_user_id
      define_method("remove_#{role}") do |base_user_id|
        base_user_role = BaseUserRole.find_by_base_user_id_and_role(base_user_id, role)
        return nil if base_user_role.nil?
        base_user_role.destroy
        
        return base_user_role
      end
      
      # 権限をもっている人数を取得する
      define_method("count_#{role}") do
        count(:conditions => ["role = ?", role])
      end
    
    end if defined? BaseUserRole.new

  end
  
end
