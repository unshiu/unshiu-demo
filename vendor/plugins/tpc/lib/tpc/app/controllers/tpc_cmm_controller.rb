module TpcCmmControllerModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        before_filter :login_required, :only => ['commented_list', 'latest_list']
        before_filter :authorized_view_required, :only => ["show", 'comments']
        before_filter :authorized_create_required, :only => ['new_comment', 'comment_confirm', 'comment_complete', 'create_remote']
        before_filter :authorized_delete_required, :only => [ 'delete_comment_confirm', 'delete_comment_complete']
        before_filter :authorized_cmm_admin_required, :only => ['delete_confirm', 'delete_complete']
        
        nested_layout_with_done_layout_for_tpc_cmm 
      end
    end
  end
  
  # 一覧
  # 全員がアクセス可能だが、人によって一覧の内容が違う
  def list
    order = params[:order]
    order = "desc" if order.nil? || !(order =~ /^(desc|asc|comment)$/)
    
    @community = CmmCommunity.find(params[:id])
    page_size = AppResources['tpc']['topic_list_size']
    
    if order == "comment"
      @topics = TpcTopicCmmCommunity.find_by_community_id_and_max_public_level(@community.id, max_public_level(@community),
                                                                               :page => {:size => page_size, :current => params[:page]},
                                                                               :include => [:tpc_topic], :order => ["tpc_topics.comment_count desc"])
    else
      @topics = TpcTopicCmmCommunity.find_by_community_id_and_max_public_level(@community.id, max_public_level(@community),
                                                                              :page => {:size => page_size, :current => params[:page]},
                                                                              :order => ["tpc_topic_cmm_communities.updated_at #{order}"])
    end
    @members = @community.cmm_communities_base_users.recent_join(AppResources[:cmm][:portal_member_list_size])
  end
  
  def __mobile_list
    @community = CmmCommunity.find(params[:id])
    page_size = AppResources['tpc']['topic_list_size']
    
    @topics = TpcTopicCmmCommunity.find_by_community_id_and_max_public_level(@community.id, max_public_level(@community), 
                                                                             :page => {:size => page_size, :current => params[:page]},
                                                                             :order => ["tpc_topics.updated_at desc"])
  end
  
  # 検索
  def search
    @community = CmmCommunity.find(params[:id])
    @keyword = params[:keyword] || ''
    page_size = AppResources['tpc']['topic_list_size']
    @topics = TpcTopicCmmCommunity.keyword_search_by_community_id_and_max_public_level(@community.id, max_public_level(@community), @keyword, :page => {:size => page_size, :current => params[:page]})
  end
  
  # トピック詳細
  def show
    order = params[:comment_order]
    order = "desc" if order.nil? || !(order =~ /^(desc|asc)$/) 
    
    @topic = TpcTopicCmmCommunity.find(params[:id])
    @community = @topic.cmm_community
    @comments = @topic.tpc_topic.tpc_comments.find(:all, :order => ["created_at #{order} "], 
                                                   :page => {:size => AppResources[:tpc][:tpc_cmm_comment_list_size_with_comment], :current => params[:page]})
    unless request.mobile?
      @members = @community.cmm_communities_base_users.recent_join(AppResources[:cmm][:portal_member_list_size])
    end
  end
  
  # 自分がコメントしたトピック一覧
  def commented_list
    page_size = AppResources['tpc']['topic_list_size']

    @topics = TpcTopicCmmCommunity.find_commented_topics_by_base_user_id_and_limit_days(current_base_user.id,
      AppResources["tpc"]["portal_tpc_cmm_commented_topic_days"],
      :page => {:size => page_size, :current => params[:page]})
  end
  
  # 所属コミュニティの最新トピック一覧
  def latest_list
    page_size = AppResources['tpc']['topic_list_size']

    @topics = TpcTopicCmmCommunity.find_latest_topics_by_base_user_id_and_limit_days(current_base_user.id,
      AppResources["tpc"]["portal_tpc_cmm_latest_topic_days"],
      :page => {:size => page_size, :current => params[:page]})
  end

  # 所属してるコミュニティのトピック一覧
  def public_list
    page_size = AppResources['tpc']['topic_list_size']
    @topics = TpcTopicCmmCommunity.public_topics(:page => {:size => page_size, :current => params[:page]})
  end
  
  # コメント一覧
  def comments
    @topic = TpcTopicCmmCommunity.find(params[:id])
    page_size = AppResources['tpc']['comment_list_size']
    @comments = TpcComment.find(:all, :conditions => ["tpc_topic_id = ?", @topic.tpc_topic_id], :page => {:size => page_size, :current => params[:page]})
    unless request.mobile?
      @community = @topic.cmm_community
      @members = @topic.cmm_community.cmm_communities_base_users.recent_join(AppResources[:cmm][:portal_member_list_size])
    end
  end
  
  # コメント処理
  # コミュニティに所属してる人のみ
  def new_comment
    @topic = TpcTopicCmmCommunity.find(params[:id])
    @comment = TpcComment.new(params[:comment]) 
    @comment.tpc_topic_id = @topic.tpc_topic_id
  end
  
  def comment_confirm
    @topic = TpcTopicCmmCommunity.find(params[:id])
    @comment = TpcComment.new(params[:comment])
    
    unless @comment.valid?
      render :action => 'new_comment'
      return
    end
  end
  
  def comment_complete
    topic = TpcTopicCmmCommunity.find(params[:id])
    comment = TpcComment.new(params[:comment])
    if cancel?
      @topic = topic
      @comment = comment
      render :action => 'new_comment'
      return
    end
    
    comment.base_user_id = current_base_user.id
    comment.save
    topic.update_index(true)
    
    redirect_to :action => 'comment_done', :id => topic.id
  end
  
  def create_remote
    @topic = TpcTopicCmmCommunity.find(params[:id])
    @comment = TpcComment.new(params[:comment])
    @comment.base_user_id = current_base_user.id
    if @comment.save
      @comments = @topic.tpc_topic.tpc_comments.find(:all, :page => {:size => AppResources[:tpc][:tpc_cmm_comment_list_size_with_comment], :current => params[:page]})
      @topic.update_index(true)      
    else
      render "create_remote_error"
      return
    end
  end
  
  def comment_done
    @topic = TpcTopicCmmCommunity.find(params[:id])
  end
  
  # コメント削除
  # コメントした人か、コミュニティの管理者のみ
  def delete_comment_confirm
    @comment = TpcComment.find(params[:id])
    @topic = TpcTopicCmmCommunity.find_by_tpc_topic_id(@comment.tpc_topic_id)
    @community = @topic.cmm_community
  end
  
  def delete_comment_complete
    comment = TpcComment.find(params[:id])
    topic = TpcTopicCmmCommunity.find_by_tpc_topic_id(comment.tpc_topic_id)
    
    if cancel?
      redirect_to :action => 'show', :id => topic.id
      return
    end
    
    comment.invisible_by(current_base_user_id)
    topic.update_index(true)
    
    flash[:notice] = t('view.flash.notice.tpc_comment_delete')
    if request.mobile?
      redirect_to :action => 'delete_comment_done', :id => topic.id
    else
      redirect_to :action => :show, :id => topic.id
    end
  end
  
  def delete_comment_done
    @topic = TpcTopicCmmCommunity.find(params[:id])
  end
  
  # トピック削除
  # 管理者のみ
  def delete_confirm
    @topic = TpcTopicCmmCommunity.find(params[:id])
    @community = @topic.cmm_community
  end
  
  def delete_complete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end

    topic = TpcTopicCmmCommunity.find(params[:id])
    community_id = topic.cmm_community_id
    topic.tpc_topic.destroy
    topic.destroy
    
    flash[:notice] = t('view.flash.notice.tpc_topic_delete')
    if request.mobile?
      redirect_to :action => 'delete_done', :id => community_id
    else
      redirect_to :action => :list, :id => community_id
    end
  end
  
  def delete_done
    @community = CmmCommunity.find(params[:id])
  end

private

  # FIXME cmm_controllerにおなじメソッドがある
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

  def authorized_view_required
    topic = TpcTopicCmmCommunity.find(params[:id])
     
    if topic.accessible?(current_base_user)
      return true
    else
      if logged_in?
        redirect_to_error "U-09001"
      else
        redirect_to :controller => 'base_user', :action => 'login'
      end
      return false
    end
  end
  
  def authorized_create_required
    if current_base_user
      topic = TpcTopicCmmCommunity.find(params[:id])
      if topic.cmm_community.joined?(current_base_user.id)
        return true
      end
    end
    if logged_in?
      redirect_to_error "U-09002"
    else
      redirect_to :controller => 'base_user', :action => 'login'
    end
    return false
  end
  
  def authorized_cmm_admin_required
    if current_base_user
      topic = TpcTopicCmmCommunity.find(params[:id])
      if topic.cmm_community.admin_or_subadmin?(current_base_user.id)
        return true
      end
    end
    if logged_in?
      redirect_to_error "U-09003"
    else
      redirect_to :controller => 'base_user', :action => 'login'
    end
    return false
  end

  def authorized_delete_required
    comment = TpcComment.find(params[:id])
    topic = TpcTopicCmmCommunity.find_by_tpc_topic_id(comment.tpc_topic_id)
    
    # コメント書いた人ならtrue
    if comment.base_user_id == current_base_user.id
      return true
    end
    
    # コミュニティの管理者か副管理者ならOK
    community = topic.cmm_community
    if community.admin_or_subadmin?(current_base_user.id)
      return true
    end
    
    if logged_in?
      redirect_to_error "U-09004"
    else
      redirect_to :controller => 'base_user', :action => 'login'
    end
    return false
  end
  
  module ClassMethods
  
  private
    def nested_layout_with_done_layout_for_tpc_cmm
     methods = self.public_instance_methods
     done_methods = methods.reject { |m| !(/done$/ =~ m) }
     remote_methods = methods.reject { |m| !(/remote$/ =~ m) }

     uncmm_layout_methods = ['latest_list', 'commented_list']
     nested_layout ["application"], :only => uncmm_layout_methods
     nested_layout ["empty"], :only => remote_methods
     nested_layout ['done'], :only => done_methods
     nested_layout ["cmm_application"], :except => done_methods + remote_methods + uncmm_layout_methods
    end
  end
   
end
