# == Schema Information
#
# Table name: cmm_communities_base_users
#
#  id               :integer(4)      not null, primary key
#  cmm_community_id :integer(4)      not null
#  base_user_id     :integer(4)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#  status           :integer(4)
#

module CmmCommunitiesBaseUserModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        belongs_to :base_user
        belongs_to :cmm_community
        
        const_set('STATUS_NONE',       0) # 便宜上置いてるけれど、実際は使わないはず
        const_set('STATUS_ADMIN',      1) # コミュニティ管理者
        const_set('STATUS_SUBADMIN',   2) # コミュニティサブ管理者
        const_set('STATUS_MEMBER',    10) # コミュニティメンバー
        const_set('STATUS_GUEST',     20) # ゲスト
        const_set('STATUS_APPLYING',  50) # コミュニティ参加申請中
        const_set('STATUS_REJECTED', 100) # 参加拒否
        
        # 参加者
        const_set('STATUSES_JOIN', [base::STATUS_ADMIN, base::STATUS_SUBADMIN, base::STATUS_MEMBER, base::STATUS_GUEST])
        # ステータス一覧
        const_set('STATUSES_ALL', { "status_none"     => base::STATUS_NONE, 
                                    "status_admin"    => base::STATUS_ADMIN, 
                                    "status_subadmin" => base::STATUS_SUBADMIN, 
                                    "status_member"   => base::STATUS_MEMBER, 
                                    "status_guest"    => base::STATUS_GUEST, 
                                    "status_applying" => base::STATUS_APPLYING, 
                                    "status_rejected" => base::STATUS_REJECTED })
        
        named_scope :recent_join, lambda { |limit| 
          {:conditions => [' status in (?)', CmmCommunitiesBaseUser::STATUSES_JOIN], :limit => limit, :order => ['created_at desc'] } 
        }
      end
    end
  end
  
  def admin?
    return status == CmmCommunitiesBaseUser::STATUS_ADMIN
  end
  def subadmin?
    return status == CmmCommunitiesBaseUser::STATUS_SUBADMIN
  end
  def member?
    return status == CmmCommunitiesBaseUser::STATUS_MEMBER
  end
  def guest?
    return status == CmmCommunitiesBaseUser::STATUS_GUEST
  end
  def applying?
    return status == CmmCommunitiesBaseUser::STATUS_APPLYING
  end
  def rejected?
    return status == CmmCommunitiesBaseUser::STATUS_REJECTED
  end
  
  # ステータス名称を返す
  def status_name
    CmmCommunitiesBaseUser::STATUSES_ALL.each_pair do |key, value|
      if self.status == value
        return I18n.t("view.noun.#{key.downcase}")
      end
    end
  end
  
  module ClassMethods
    # base_user_idのユーザーが参加しているコミュニティを探す。
    def find_joined_communities_by_user_id(base_user_id, options = {})
      options.merge!(:conditions => ["base_user_id = ? and status in (?)", base_user_id, CmmCommunitiesBaseUser::STATUSES_JOIN])
      return find(:all, options)
    end
  
    # base_user_idのユーザーが参加申請しているコミュニティを探す。
    def find_applying_communities_by_user_id(base_user_id, options = {})
      options.merge!(:conditions => ["base_user_id = ? and status = ?", base_user_id, CmmCommunitiesBaseUser::STATUS_APPLYING])
      return find(:all, options)
    end
  
    # base_user_idのユーザーが参加拒否されているコミュニティを探す。
    def find_rejected_communities_by_user_id(base_user_id, options = {})
      options.merge!(:conditions => ["base_user_id = ? and status = ?", base_user_id, CmmCommunitiesBaseUser::STATUS_REJECTED])
      return find(:all, options)
    end
  
    # cmm_community_idのコミュニティに参加しているユーザーを探す。
    def find_joined_by_community_id(cmm_community_id)
      return find(:all, :conditions => ["cmm_community_id = ? and status in (?)", cmm_community_id, CmmCommunitiesBaseUser::STATUSES_JOIN])
    end
  end

end
