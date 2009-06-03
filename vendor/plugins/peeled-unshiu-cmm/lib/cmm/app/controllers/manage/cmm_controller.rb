module ManageCmmControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    redirect_to :action => 'list'
  end
  
  # コミュニティ詳細
  def show
    @community = CmmCommunity.find(params[:id])
  end

  # 一覧
  def list
    @communities = CmmCommunity.find(:all, :order => 'created_at desc',
                                     :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end
  
  def search
    @keyword = params[:keyword]
    @communities = CmmCommunity.keyword_search(@keyword, 
                                               :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
    render :action => 'list'
  end
  
  # メンバー一覧
  def member_list
    @state = params[:state].to_i
    join_status = @state != 0 ? @state : CmmCommunitiesBaseUser::STATUSES_JOIN
    
    @community = CmmCommunity.find(params[:id])
    @members = CmmCommunitiesBaseUser.find(:all,
                                           :conditions => ['cmm_community_id = ? and status in (?)', params[:id], join_status],
                                           :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end
  
  # コミュニティを破棄する
  alias :destroy_confirm :show
  def destroy_complete
    id = params[:id]
    
    if cancel?
      redirect_to :action => 'show', :id => id
      return
    end
    
    community = CmmCommunity.find(id)
    community.destroy
    
    flash[:notice] = "#{I18n.t('view.noun.cmm_community')}「#{community.name}」を削除しました。"
    redirect_to :action => 'list'
  end

  # 検索
  def search_redirector
    keyword = params[:keyword]
    type = params[:type].to_i
    if type == 0
      redirect_to :controller => 'cmm', :action => 'search', :keyword => keyword
    elsif type == 1
      redirect_to :controller => 'tpc_cmm', :action => 'allsearch', :keyword => keyword
    elsif type == 2
      redirect_to :controller => 'tpc_cmm', :action => 'search', :id => params[:id], :keyword => keyword
    end
  end
end
