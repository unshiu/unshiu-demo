module CmmHelperModule
  # コミュニティ役職のview用文字列を返す
  def post(cmm_community_base_user)
    if cmm_community_base_user.admin?
      "(#{I18n.t('activerecord.constant.status.status_admin')})"
    elsif cmm_community_base_user.subadmin?
      "(#{I18n.t('activerecord.constant.status.status_subadmin')})"
    elsif cmm_community_base_user.guest?
      "(#{I18n.t('activerecord.constant.status.status_guest')})"
    else
      ''
    end
  end
  
  def cmm_community_current
    if @controller.controller_name == "cmm" || @controller.controller_name == "cmm_admin" 
      true
    end
  end
  
  def tpc_topic_currnet
    if @controller.controller_name == "tpc" || @controller.controller_name == "tpc_cmm"
      true
    end
  end
  
  def member_currnet
    if @controller.controller_name == "cmm_member"
      true
    end
  end
  
end