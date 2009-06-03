module CmmMemberControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        nested_layout_with_done_layout "cmm_application"
      end
    end
  end
  
  # 一覧
  def list
    id = params[:id]

    page_size = AppResources["cmm"]["member_list_size"]
    @community = CmmCommunity.find(id)
    @members = CmmCommunitiesBaseUser.find(:all,
      :conditions => ['cmm_community_id = ? and status in (?)', id, CmmCommunitiesBaseUser::STATUSES_JOIN],
      :page => {:size => page_size, :current => params[:page]}
      )
  end
  
end
