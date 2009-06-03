module TpcControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        before_filter :authorized_tpc_create_required, :only => ['create_confirm', 'create_complete']
        
        nested_layout_with_done_layout "cmm_application"   
      end
    end
  end

  # つくる
  def new_cmm_topic
    community_id = params[:id]
    @community = CmmCommunity.find(community_id)
    @topic = TpcTopic.new(params[:topic])
    @topic_info = TpcTopicCmmCommunity.new(params[:topic_info])
    @topic_info.public_level ||= TpcRelationSystem::PUBLIC_LEVEL_ALL
    @topic_info.cmm_community_id = @community.id
  end
  
  def create_confirm
    @topic = TpcTopic.new(params[:topic])    
    if params[:topic_type] == 'TpcTopicCmmCommunity'
      @topic_info = TpcTopicCmmCommunity.new(params[:topic_info])
      @community = @topic_info.cmm_community
    end
    
    unless @topic.valid?
      render :action => 'new_cmm_topic'
      return
    end
  end
  
  def create_complete
    @topic = TpcTopic.new(params[:topic])
    if params[:topic_type] == 'TpcTopicCmmCommunity'
      @topic_info = TpcTopicCmmCommunity.new(params[:topic_info])
    end
    
    if cancel?
      @community = @topic_info.cmm_community
      render :action => 'new_cmm_topic'
      return
    end
    
    @topic.base_user_id = current_base_user.id
    if @topic.save
      @topic_info.tpc_topic_id = @topic.id
      @topic_info.save
      if params[:topic_type] == 'TpcTopicCmmCommunity'
        flash[:notice] = t('view.flash.notice.tpc_topic_create')
        if request.mobile?
          redirect_to :action => 'create_cmm_topic_done', :id => @topic_info.id
        else
          redirect_to :controller => :cmm, :action => :show, :id => @topic_info.cmm_community_id
        end
      end
    else
      @community = @topic_info.cmm_community
      render :action => 'new_cmm_topic'
      return
    end
  end
  
  def create_cmm_topic_done
    @topic_info = TpcTopicCmmCommunity.find(params[:id])
    @community = @topic_info.cmm_community
  end

private
  
  def authorized_tpc_create_required
    # コミュニティのtopicじゃなかったらとりあえずtrue
    return true if params[:topic_type] != 'TpcTopicCmmCommunity'
    
    topic_info = TpcTopicCmmCommunity.new(params[:topic_info])
    community = CmmCommunity.find(topic_info.cmm_community_id)
    if community.nil? || !community.topic_creatable?(current_base_user.id)
      redirect_to_error "U-09005"
      return
    end
    return true
  end
  
end
