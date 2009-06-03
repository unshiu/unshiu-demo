module CmmUserControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        
        nested_layout_with_done_layout 
      end
    end
  end
  
  # ユーザが所属してるコミュニティ一覧
  def list
    user_id = params[:id]
    user_id = current_base_user.id if !user_id
    
    @user = BaseUser.find(user_id)

    page_size = AppResources['cmm']['community_list_size']
    if @user
      @communities = CmmCommunitiesBaseUser.find_joined_communities_by_user_id(@user.id,
        :page => {:size => page_size, :current => params[:page]})
    end
  end
  
  # ユーザが申請中のコミュニティ一覧
  def applying_list
    page_size = AppResources['cmm']['community_list_size']
    @communities = CmmCommunitiesBaseUser.find_applying_communities_by_user_id(current_base_user.id,
        :page => {:size => page_size, :current => params[:page]})
  end
  
end
