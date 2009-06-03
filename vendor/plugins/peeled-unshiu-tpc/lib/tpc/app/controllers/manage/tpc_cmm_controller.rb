module ManageTpcCmmControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # トピック
  def show
    @topic = TpcTopicCmmCommunity.find(params[:id])
    @comments = TpcComment.find(:all, :conditions => ["tpc_topic_id = ?", @topic.tpc_topic_id], 
                                :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
    @community = @topic.cmm_community
  end

  # コミュニティ内のトピック一覧
  def list
    @community = CmmCommunity.find(params[:id])
    @topics = TpcTopicCmmCommunity.find(:all, :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]},
                                        :conditions => ["cmm_community_id = ?", @community.id], :order => 'created_at desc')
  end
  
  # コミュニティ横断でのトピック一覧
  def alllist
    @topics = TpcTopicCmmCommunity.find(:all, :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]},
                                        :order => 'created_at desc')
  end
  
  # 検索
  def search
    @community = CmmCommunity.find(params[:id])
    @keyword = params[:keyword] || ''
    
    @topics = TpcTopicCmmCommunity.keyword_search_by_community_id_and_max_public_level(@community.id, TpcRelationSystem::PUBLIC_LEVEL_ALL, @keyword, 
                                                                                       :page => {:size => AppResources["mng"]["standard_list_size"], 
                                                                                       :current => params[:page]})
    render :action => 'list'
  end

  # 検索
  def allsearch
    @keyword = params[:keyword] || ''
    
    @topics = TpcTopicCmmCommunity.keyword_search(@keyword, :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
    render :action => 'alllist'
  end

  # トピック削除
  def delete_confirm
    @topic = TpcTopicCmmCommunity.find(params[:id])
    @community = @topic.cmm_community
  end
  
  def delete_complete
    topic = TpcTopicCmmCommunity.find(params[:id])
    
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    
    topic.tpc_topic.destroy
    topic.destroy
    
    flash[:notice] = "#{I18n.t('view.noun.tpc_topic')}「#{topic.tpc_topic.title}」を削除しました。"
    redirect_to :controller => 'manage/cmm', :action => 'show', :id => topic.cmm_community_id
  end

  # コメント削除
  def delete_comment_confirm
    @comment = TpcComment.find(params[:id])
    @topic = TpcTopicCmmCommunity.find_by_tpc_topic_id(@comment.tpc_topic_id)
    @community = @topic.cmm_community
  end
  
  def delete_comment_complete
    comment = TpcComment.find(params[:id])
    
    if cancel?
      redirect_to :action => 'show', :id => comment.tpc_topic_id
      return
    end
    
    topic = TpcTopicCmmCommunity.find_by_tpc_topic_id(comment.tpc_topic_id)    
    comment.invisible_by(current_base_user_id)
    topic.update_index(true)
    
    flash[:notice] = "#{I18n.t('view.noun.tpc_comment')}を削除しました。"
    redirect_to :action => 'show', :id => topic.id
  end
end
