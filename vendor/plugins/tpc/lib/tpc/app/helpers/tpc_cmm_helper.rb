module TpcCmmHelperModule
  
  def deletable?(topic)
    return false unless topic.kind_of? TpcTopicCmmCommunity

    community = topic.cmm_community
    return community.user_status_in?(current_base_user.id, [CmmCommunitiesBaseUser::STATUS_ADMIN, CmmCommunitiesBaseUser::STATUS_SUBADMIN])
  end

  def deletable_comment?(comment)
    return false unless logged_in?
    return true if current_base_user.me?(comment.base_user_id)
    ttcc = TpcTopicCmmCommunity.find_by_tpc_topic_id(comment.tpc_topic_id)
    community = ttcc.cmm_community
    return true if community.admin_or_subadmin?(current_base_user.id)
    return false
  end
end
