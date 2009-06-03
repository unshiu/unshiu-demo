module CmmAdminControllerModule

  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        before_filter :admin_filter, :only => ['destroy_confirm', 'destroy_complete', 'member_list', 'mail', 'image', 'image_upload']
        before_filter :admin_filter_by_ccbu, 
                      :only => ['approve_confirm', 'approve_complete', 'member_status_confirm', 'member_status_complete']
        before_filter :admin_or_subadmin_filter, 
                      :only => ['edit', 'edit_confirm', 'edit_complete']
        before_filter :valid_change_member_status, :only => ['member_status_confirm', 'member_status_complete']
        nested_layout_with_done_layout "cmm_application"
      end
    end
  end
  
  # 設定する
  def edit
    id = params[:id]
    if params[:community]
      @community = CmmCommunity.new(params[:community])
      @community.id = id
    else
      @community = CmmCommunity.find(id)
    end
  end
  
  def edit_confirm
    id = params[:id]
    @community = CmmCommunity.find(id)
    @community.attributes = @community.attributes.merge(params[:community])
    
    unless @community.valid?
      render :action => 'edit'
      return
    end
  end
  
  def edit_complete
    #params[:id]のcommunityをparams[:community]の値にする。
    id = params[:id]
    community = CmmCommunity.find(id)
    community.attributes = community.attributes.merge(params[:community])
    if cancel? || !community.valid?
      @community = community
      render :action => 'edit'
      return
    end
    
    community.save
    if community.join_type_free?
      community.applying_users.each do |ccbu|
        ccbu.status = CmmCommunitiesBaseUser::STATUS_MEMBER
      end
    end
    
    if request.mobile?
      redirect_to :action => 'edit_done', :id => community.id
    else
      redirect_to :controller => :cmm, :action => :show, :id => community.id
    end
  end
  
  def edit_done
    id = params[:id]
    @community = CmmCommunity.find(id)
  end
  
  def mail
    @community = CmmCommunity.find(params[:id])
    @mail_address = BaseMailerNotifier.mail_address(current_base_user.id, "CmmCommunity", "receive", params[:id])
  end

  def image
    @community = CmmCommunity.find(params[:id])
  end
  
  def image_upload
    @community = CmmCommunity.find(params[:id])
    unless params[:upload_file]
      flash[:error] = t('view.flash.error.cmm_community_image_update_no_image')
      render :action => :image
      return
    end
    
    @cmm_image = @community.cmm_image
    if @cmm_image
      @cmm_image.image = params[:upload_file][:image]
    else
      @cmm_image = CmmImage.new(:cmm_community_id => @community.id, :image => params[:upload_file][:image])
    end
    
    if @cmm_image.save
      flash[:notice] = t('view.flash.notice.cmm_community_image_update')
      redirect_to :controller => :cmm, :action => :show, :id => @community.id
    else
      @community = CmmCommunity.find(params[:id]) # 上書きされた画像データをリセット
      flash[:error] = t('view.flash.error.cmm_community_image_update')
      render :action => :image
    end
  end
  
  # 参加申請を承認とか
  def approve_confirm
    @state = params[:state].to_i
    @ccbu = CmmCommunitiesBaseUser.find(params[:id])
    @return_to = params[:return_to]
    @community = @ccbu.cmm_community
    if @ccbu && @ccbu.applying? &&
      (@state == CmmCommunitiesBaseUser::STATUS_MEMBER || 
       @state == CmmCommunitiesBaseUser::STATUS_REJECTED || 
       @state == CmmCommunitiesBaseUser::STATUS_NONE)
    else
      redirect_to_error "U-03001"
      return
    end
  end
  
  def approve_complete
    state = params[:state].to_i
    ccbu = CmmCommunitiesBaseUser.find(params[:id])
    
    if cancel?
      if request.mobile?
        redirect_to :controller => 'cmm', :action => 'show', :id => ccbu.cmm_community_id
      else
        redirect_to CGI.unescape(params[:return_to])
      end
      return
    end
    
    if ccbu && ccbu.applying? &&
      (state == CmmCommunitiesBaseUser::STATUS_MEMBER || state == CmmCommunitiesBaseUser::STATUS_REJECTED || state == CmmCommunitiesBaseUser::STATUS_NONE)
      if state == CmmCommunitiesBaseUser::STATUS_MEMBER || state == CmmCommunitiesBaseUser::STATUS_REJECTED
        ccbu.status = state
        ccbu.save
      elsif state == CmmCommunitiesBaseUser::STATUS_NONE
        ccbu.destroy
      end
      
      if request.mobile?
        redirect_to :action => 'approve_done', :id => ccbu.cmm_community_id
      else
        redirect_to CGI.unescape(params[:return_to])
      end
    else
      redirect_to_error "U-03002"
      return
    end
  end
  
  def approve_done
    @community = CmmCommunity.find(params[:id])
  end

  # メンバー管理
  def member_list
    id = params[:id]
    @state = params[:state].to_i
    @state = @state != 0 ? @state : CmmCommunitiesBaseUser::STATUSES_JOIN

    page_size = AppResources["cmm"]["member_list_size"]
    @community = CmmCommunity.find(id)
    @members = CmmCommunitiesBaseUser.find(:all,
                                           :conditions => ['cmm_community_id = ? and status in (?)', id, @state],
                                           :page => {:size => page_size, :current => params[:page]})
  end

  # メンバーのステータスを変更する
  # 現状はメンバーをアクセス拒否、もしくは脱退させるために使う 080701
  def member_status_confirm
    id = params[:id]
    @state = params[:state].to_i
    @ccbu = CmmCommunitiesBaseUser.find(id)
    
    if @ccbu.base_user_id == current_base_user.id
      redirect_to_error "U-03004"
      return
    end
  end

  def member_status_complete
    id = params[:id]
    state = params[:state].to_i
    ccbu = CmmCommunitiesBaseUser.find(id)

    if cancel?
      if state == CmmCommunitiesBaseUser::STATUS_MEMBER
        redirect_to :controller => 'cmm_admin', :action => 'member_list', :id => ccbu.cmm_community_id, :state => ccbu.status
      else 
        redirect_to :controller => 'cmm_admin', :action => 'member_list', :id => ccbu.cmm_community_id
      end
      return
    end
    
    
    if ccbu.base_user_id == current_base_user.id
      redirect_to_error "U-03005"
      return
    end

    if state == CmmCommunitiesBaseUser::STATUS_NONE 
      ccbu.destroy
    else
      ccbu.status = state
      ccbu.save
    end
    redirect_to :action => 'member_status_done', :id => ccbu.cmm_community_id
  end
  
  def member_status_done
    @community = CmmCommunity.find(params[:id])
  end
  
  # コミュニティを破棄する
  def destroy_confirm
    @community = CmmCommunity.find(params[:id])
  end
  
  def destroy_complete
    id = params[:id]
    
    if cancel?
      redirect_to :controller => 'cmm', :action => 'show', :id => id
      return
    end
    
    community = CmmCommunity.find(id)
    community.destroy
    
    flash[:notice] = t('view.flash.notice.cmm_community_delete')
    if request.mobile?
      redirect_to :action => 'destroy_done'
    else
      redirect_to :controller => :cmm_user, :action => :list
    end
  end
  
  def destroy_done
  end
  
  private
  def admin_filter
    id = params[:id]
    community = CmmCommunity.find(id)
    unless check_community_admin?(community, current_base_user)
      redirect_to_error "U-03006"
      return false
    end
  end

  private
  def admin_filter_by_ccbu
    id = params[:id]
    ccbu = CmmCommunitiesBaseUser.find(id)
    community = ccbu.cmm_community
    unless check_community_admin?(community, current_base_user)
      redirect_to_error "U-03007"
      return false
    end
  end

  def admin_or_subadmin_filter
    id = params[:id]
    community = CmmCommunity.find(id)
    
    unless check_community_admin_or_subadmin?(community, current_base_user)
      redirect_to_error "U-03008"
      return false
    end
  end
  
  def check_community_admin?(cmm_community, base_user)
    return false unless cmm_community
    return false unless base_user
    return cmm_community.admin?(current_base_user.id)
  end
  
  def check_community_admin_or_subadmin?(cmm_community, base_user)
    return false unless cmm_community
    return false unless base_user
    return cmm_community.admin_or_subadmin?(current_base_user.id)
  end

  # メンバー、アクセス拒否と脱退以外へステータスを変更しようとしている場合を例外とするフィルター
  def valid_change_member_status
    status = [CmmCommunitiesBaseUser::STATUS_REJECTED, CmmCommunitiesBaseUser::STATUS_NONE, CmmCommunitiesBaseUser::STATUS_MEMBER]
    unless status.include?(params[:state].to_i)
      redirect_to_error "U-03003"
      return
    end
  end
  
end
