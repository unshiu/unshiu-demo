module BaseControllerModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.before_filter :login_required,
        :except => ['index', 'error', 'search', '__mobile_search', 'inquire_input', 'inquire_confirm', 'inquire', 
                    'inquire_done', 'docomo_entrance', 'device', 'device_change']
      base.nested_layout_with_done_layout_for_portal
    end
  end
  
  def index
    setup_notices
    @entries = DiaEntry.cache_portal_public_entries
    @albums = AbmAlbum.cache_portal_public_albums
    @communities = CmmCommunity.cache_portal_communities
    @topics = TpcTopicCmmCommunity.cache_portal_topics
  end
  
  # pnt_filter_title:ポータルを表示する
  def portal
    setup_notices
    @friends_count = current_base_user.friends.count
    @favorites_count = current_base_user.favorites.count
    @dia_entries_count = current_base_user.dia_entries.count
    @abm_albums_count = current_base_user.abm_albums.count
    @communities_count = current_base_user.cmm_communities.count
    
    @friend_entries = DiaEntry.friend_entries(current_base_user, :limit => AppResources["dia"]["portal_frined_entry_list_size"])
    @friend_albums = AbmAlbum.friend_albums(current_base_user, :limit => AppResources["abm"]["portal_album_list_size"])
    @commented_entries = current_base_user.dia_commented_entries.find(:all, :limit => AppResources["dia"]["portal_commented_entry_list_size"])
    @communities = current_base_user.cmm_communities.find(:all, :limit => AppResources["cmm"]["portal_community_list_size"])
    @community_latest_topics = TpcTopicCmmCommunity.find_latest_topics_by_base_user_id_and_limit_days(current_base_user.id,
                                                                                                      AppResources["tpc"]["portal_tpc_cmm_latest_topic_days"],
    :limit => AppResources["tpc"]["portal_tpc_cmm_latest_topic_size"])
    @community_commented_topics = TpcTopicCmmCommunity.find_commented_topics_by_base_user_id_and_limit_days(current_base_user.id,
                                                                                                            AppResources["tpc"]["portal_tpc_cmm_commented_topic_days"],
    :limit => AppResources["tpc"]["portal_tpc_cmm_commented_topic_size"])      
    
    @profile = current_base_user.base_profile
  end
  
  def search
    @form = Forms::BaseSearchForm.new(params[:base_search])
    case @form.scope
    when "base_user"
      if @form.keyword.empty?
        @results = BaseUser.active.find(:all, :page => {:size => AppResources[:base][:search_result_list_size], :current => params[:page]})
      else
        @results = BaseUser.active.find(:all, :conditions => ['name like ?', "%#{@form.keyword}%"], 
                                              :page => {:size => AppResources[:base][:search_result_list_size], :current => params[:page]})
      end
    when "dia"
      @results = DiaEntry.public_entries_keyword_search(@form.keyword, :page => {:size => AppResources[:base][:search_result_list_size], :current => params[:page]})
    when "abm"
      @results = AbmImage.public_all.find_images_by_keyword_with_paginate(@form.keyword, AppResources[:base][:search_result_list_size], params[:page])
    when "cmm"
      @results = CmmCommunity.keyword_search(@form.keyword, :page => {:size => AppResources[:base][:search_result_list_size], :current => params[:page]})
    end
  end

  def __mobile_search
  end
  
  # お問い合わせ
  def inquire_input
    @inquire = BaseInquire.new
    @inquire.referer = request.env['HTTP_REFERER']
  end
  
  def inquire_confirm
    @inquire = BaseInquire.new(params[:inquire])
    
    if logged_in? && !@inquire.mail_address
      @inquire.mail_address = current_base_user.email
    end
    
    unless @inquire.valid?
      render :action => 'inquire_input'
      return
    end
  end
  
  def inquire
    inq = BaseInquire.new(params[:inquire])
    if current_base_user && !inq.mail_address
      inq.mail_address = current_base_user.email
      inq.base_user_id = current_base_user.id
    end
    inq.save
    
    if cancel?
      @inquire = inq
      render :action => 'inquire_input'
      return
    end
    
    MngMailerNotifier.deliver_inquire_to_manager(inq.mail_address, inq.body, inq.referer)
    if request.mobile?
      redirect_to :action => 'inquire_done'
    else
      flash[:notice] = t('view.flash.notice.base_inquire_create')
      redirect_to :controller => 'base', :action => 'index'
    end
  end

  def inquire_done
  end
  
  def error
    @error_message = params[:error_message]
    @error_code = params[:error_code]
    @next_url = params[:next_url]
  end

  # 機種変更に関して
  def device_change
  end
  
  # 対応機種について
  def device
  end
  
  # メニュー一覧の更新処理　RJS用
  def menus_update
    BaseMenu.resetting_menu(current_base_user.id, params[:base_menu_master_id].to_i, params[:num].to_i)
    @base_menus = BaseMenu.find(:all, :conditions => ["base_user_id = ? and show_flag = true", current_base_user], :order => ["num"])
    @base_sub_menus = BaseMenu.find(:all, :conditions => ["base_user_id = ? and show_flag = false", current_base_user], :order => ["num"])
  end
  
private

  def setup_notices
    @notices = BaseNotice.current_notices # limit はなしに変更
    if logged_in?
      @unread_messages_count = current_base_user.msg_unread_messages.count
      @friend_applies_count = current_base_user.friend_applies.count
      @unread_entry_comments_count = DiaEntryComment.count_unread_entry_comments_by_base_user_id(current_base_user_id)
      if @unread_entry_comments_count && @unread_entry_comments_count != 0
        @oldest_unread_comment = DiaEntryComment.find_oldest_unread_comment_by_base_user_id(current_base_user_id)
      end
    end
  end

  module ClassMethods
    def nested_layout_with_done_layout_for_portal
      methods = self.public_instance_methods
      done_methods = methods.reject{|m|
        index = m.index('done')
        index.nil? || index + 'done'.length < m.length
      }
      portal_methods = ['index', 'portal']
      nested_layout nil, :except => done_methods + portal_methods
      nested_layout ['portal'], :only => portal_methods
      nested_layout ['done'], :only => done_methods
    end
  end
end
