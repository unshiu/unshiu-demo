module CmmControllerModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        before_filter :login_required, :except => ['show', 'list', 'search']
        before_filter :community_exist_filter,
            :except => ['list', 'search', 'new', 'create_confirm', 'create_complete', 'resign_done']
        
        nested_layout_with_done_layout_for_cmm
      end
    end
  end
  
  # コミュニティ詳細
  def show
    @community = CmmCommunity.find(params[:id])
    @image = @community.cmm_image
    
    @topics = TpcTopicCmmCommunity.find_by_community_id_and_max_public_level(@community.id, max_public_level(@community), 
                                                                             {:page => { :size => AppResources[:tpc][:cmm_show_list_size], :current => 0},
                                                                              :order => "tpc_topics.last_commented_at desc"})
    unless request.mobile?
      @members = @community.cmm_communities_base_users.recent_join(AppResources[:cmm][:portal_member_list_size])
    end
  end

  # 一覧
  def list
    page_size = AppResources["cmm"]["community_list_size"]
    @communities = CmmCommunity.find(:all, :page => {:size => page_size, :current => params[:page]}, :order => 'created_at desc')
  end

  def search
    @keyword = params[:keyword]
    page_size = AppResources["cmm"]["community_list_size"]
    @communities = CmmCommunity.keyword_search(@keyword, :page => {:size => page_size, :current => params[:page]})
  end

  # 作る
  def new
    @community = CmmCommunity.new(params[:community])
    
    @community.join_type ||= AppResources["cmm"]["default_join_type"]
    @community.topic_create_level ||= AppResources["cmm"]["default_topic_create_level"]
  end
  
  # 以下の内容で作成しますか？ 画面
  def create_confirm
    @community = CmmCommunity.new(params[:community])
    unless @community.valid?
      render :action => 'new'
      return
    end
  end
  
  # 作成完了
  def create_complete
    @community = CmmCommunity.new(params[:community])
    
    if cancel?
      render :action => 'new'
      return
    end
    
    unless @community.valid?
      render :action => 'new'
      return
    end
    
    @community.save
    ccbu = CmmCommunitiesBaseUser.new(:cmm_community_id => @community.id,
      :base_user_id => current_base_user.id,
      :status => CmmCommunitiesBaseUser::STATUS_ADMIN)
    ccbu.save
    
    flash[:notice] = t('view.flash.notice.cmm_community_create')
    if request.mobile?
      redirect_to :action => 'create_done', :id => @community.id
    else
      redirect_to :controller => :cmm_user, :action => :list
    end
  end
  
  # 作成完了しました画面
  def create_done
  end
  
  # 参加確認
  def join_confirm
    @community = CmmCommunity.find(params[:id])
  end
  
  # 参加完了
  def join_complete
    community = CmmCommunity.find(params[:id])
    
    if cancel?
      redirect_to :action => :show, :id => community.id
      return
    end
    
    ccbu = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(community.id, current_base_user.id)
    if ccbu
      redirect_to_error "U-03009"
      return
    else
      ccbu = CmmCommunitiesBaseUser.new(:cmm_community_id => community.id, :base_user_id => current_base_user.id)
      if community.join_type_free?
        flash[:notice] = t('view.flash.notice.cmm_community_join')
        ccbu.status = CmmCommunitiesBaseUser::STATUS_MEMBER
      else
        flash[:notice] = t('view.flash.notice.cmm_community_join_apply')
        ccbu.status = CmmCommunitiesBaseUser::STATUS_APPLYING
      end
      ccbu.save
    end
    
    if request.mobile?
      redirect_to :action => 'join_done', :id => community.id
    else
      redirect_to :action => 'show', :id => community.id
    end
  end
  
  # 参加しました画面
  def join_done
    @community = CmmCommunity.find(params[:id])
  end
  
  # 脱退しよう
  # 脱退確認
  def resign_confirm
    @community = CmmCommunity.find(params[:id])
    if @community.admin?(current_base_user.id)
      redirect_to_error "U-03010"
      return
    end
  end
  
  def resign_complete
    if cancel?
      redirect_to :action => :show, :id => params[:id]
      return
    end
    
    community = CmmCommunity.find(params[:id])
    if community.admin?(current_base_user.id)
      redirect_to_error "U-03011"
      return
    end
    
    ccbu = CmmCommunitiesBaseUser.find_by_cmm_community_id_and_base_user_id(params[:id], current_base_user.id)
    if !ccbu.nil? && ccbu.destroy
      if request.mobile?
        redirect_to :action => 'resign_done', :id => params[:id]
        return
      else
        flash[:notice] = t('view.flash.notice.cmm_community_resign')
        redirect_to :controller => :cmm_user, :action => :list
        return
      end
    else
      redirect_to_error "U-03012"
      return
    end
  end
  
  def resign_done
    @community = CmmCommunity.find(params[:id])
  end

private
  
  def community_exist_filter
    community = CmmCommunity.find_by_id(params[:id])
    unless community
      redirect_to_error 'U-03013'
    end
  end
  
  def max_public_level(cmm_community)
    max_level = TpcRelationSystem::PUBLIC_LEVEL_ALL
    if logged_in?
      if cmm_community.joined?(current_base_user.id)
        max_level = TpcRelationSystem::PUBLIC_LEVEL_PARTICIPANT
      else
        max_level = TpcRelationSystem::PUBLIC_LEVEL_USER
      end
    end
    max_level
  end
  
  module ClassMethods
    def nested_layout_with_done_layout_for_cmm
      methods = self.public_instance_methods
      done_methods = methods.reject { |m| !(/done$/ =~ m) }
      remote_methods = methods.reject { |m| !(/remote$/ =~ m) }
      
      uncmm_layout_methods = ['new']
      nested_layout ["application"], :only => uncmm_layout_methods
      nested_layout ["empty"], :only => remote_methods
      nested_layout ['done'], :only => done_methods
      nested_layout ["cmm_application"], :except => done_methods + remote_methods + uncmm_layout_methods
    end
  end
end
