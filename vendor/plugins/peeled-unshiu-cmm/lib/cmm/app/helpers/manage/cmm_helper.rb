module ManageCmmHelperModule
  
  def cmm_member_status(state)
    case state
      when CmmCommunitiesBaseUser::STATUS_REJECTED
        I18n.t('activerecord.constant.status.status_rejected')
      when CmmCommunitiesBaseUser::STATUS_APPLYING
        I18n.t('activerecord.constant.status.status_applying')
      else
        I18n.t('activerecord.constant.status.status_member')
    end
  end
  
end
