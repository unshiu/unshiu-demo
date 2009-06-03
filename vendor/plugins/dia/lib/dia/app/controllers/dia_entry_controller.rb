module DiaEntryControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required, :except => ["list", "__mobile_list", "show", "public_list", "search"]
        before_filter :nil_check, :only => ["show", "show_image", "edit", "update_confirm", "update", "delete_confirm", "delete"]
        before_filter :access_filter, :only => ["show", "show_image"]
        before_filter :entry_image_access_filter, :only => ["show_image"]
        before_filter :album_owner_only, :only => ["album_show"]
        before_filter :owner_only, :only => ["edit", "update_confirm", "update", "delete_confirm", "delete"]
        before_filter :images_access_filter, :only => ['new', 'confirm', 'create', 'edit', 'update_confirm', 'update']
        
        nested_layout_with_done_layout
      end
    end
  end
  
  def list
    @diary = get_diary
    @entries = @diary.accesible_entries(current_base_user).find(:all, :page => {:size => AppResources[:dia][:entry_list_size], :current => params[:page]})
    @recent_dia_entries = @diary.accesible_entries(current_base_user).find(:all, :limit => AppResources[:dia][:recent_entry_list_size])
    @recent_dia_entry_comments = DiaEntryComment.accesible_comments(@diary, current_base_user).find(:all, :limit => AppResources[:dia][:recent_comment_list_size])
  end
  
  def __mobile_list
    @diary = get_diary
    @entries = @diary.accesible_entries(current_base_user).find(:all, :page => {:size => AppResources[:dia][:entry_list_size_mobile], :current => params[:page]})
  end
  
  def draft_list
    @diary = get_diary
    unless current_base_user.me?(@diary.base_user_id)
      redirect_to_error("U-04003")
      return
    end
    key = Util.resources_keyname_from_device("entry_list_size", request.mobile?)
    @entries = @diary.dia_draft_entries.find(:all, :page => {:size => AppResources["dia"][key], :current => params[:page]})    
  end
  
  def commented_list
    key = Util.resources_keyname_from_device("entry_list_size", request.mobile?)
    @entries = current_base_user.dia_commented_entries.find(:all, :page => {:size => AppResources[:dia][key], :current => params[:page]})
  end
  
  def friend_list
    @entries = DiaEntry.friend_entries(current_base_user, :page => {:size => AppResources[:dia][:entry_list_size], :current => params[:page]})
  end

  def __mobile_friend_list
    @entries = DiaEntry.friend_entries(current_base_user, :page => {:size => AppResources[:dia][:entry_list_size_mobile], :current => params[:page]})
  end
  
  def public_list
    key = Util.resources_keyname_from_device("entry_list_size", request.mobile?)
    @entries = DiaEntry.public_entries(:page => {:size => AppResources[:dia][key], :current => params[:page]})
  end
  
  def search
    @keyword = params[:keyword]
    @entries = DiaEntry.public_entries_keyword_search(@keyword, :page => {:size => AppResources[:dia][:entry_list_size_mobile], :current => params[:page]})
  end
  
  def new
    @diary = get_diary
    @dia_entry = DiaEntry.new
    @dia_entry.public_level = get_diary.default_public_level
    @images = params[:images] ? AbmImage.find(params[:images].split(/\s*,\s*/)) : []
    @image_ids = @images.collect{|image| image.id}.join(',')
    unless request.mobile?
      @abm_albums = AbmAlbum.find_my_albums_with_pagenate(current_base_user.id, AppResources[:dia][:entry_album_list_size])
    end
  end
  
  def mail
    diary = get_diary
    @mail_address = BaseMailerNotifier.mail_address(current_base_user.id, "DiaEntry", "receive", diary.id)
  end
  
  def confirm
    @diary = get_diary
    @dia_entry = DiaEntry.new(params[:dia_entry])
    @dia_entry.dia_diary_id = @diary.id
    @images = params[:images] ? AbmImage.find(params[:images].keys) : []
    unless @dia_entry.valid?
      render :action => 'new'
      return
    end
    
    if params[:draft] != nil
      @dia_entry.draft_flag = true
      @dia_entry.save
      @dia_entry.add_images(@images.collect{|image| image.id})
      
      redirect_to :action => 'draft_done'
    end
  end
  
  def draft_done
  end
  
  def create
    diary = get_diary
    @dia_entry = DiaEntry.new(params[:dia_entry])
    @dia_entry.draft_flag = true unless params[:draft].nil?
    
    if cancel?
      @images = params[:images] ? AbmImage.find(params[:images].keys) : []
      render :action => 'new'
      return
    end
    
    @dia_entry.dia_diary_id = diary.id
    @dia_entry.contributed_at = Time.now
    
    unless @dia_entry.valid?
      @images = params[:images] ? AbmImage.find(params[:images].keys) : []
      @abm_albums = AbmAlbum.find_my_albums_with_pagenate(current_base_user.id, AppResources[:dia][:entry_album_list_size])
      render :action => 'new'
      return
    end
    
    @dia_entry.save
    @dia_entry.add_images(params[:images].keys) if params[:images]
    
    flash[:notice] = t('view.flash.notice.dia_entry_create')
    if request.mobile?
      redirect_to :action => 'done', :id => @dia_entry.id
    else
      redirect_to :action => 'list'
    end
  end
  
  def done
    #render :layout => 'dia_done'
  end
  
  def edit
    @dia_entry = DiaEntry.find(params[:id])
    @diary = @dia_entry.dia_diary
    if params.has_key?(:images)
      @images = params[:images] ? AbmImage.find(params[:images].split(/\s*,\s*/)) : []
      @images_changed = true
    else
      @images = @dia_entry.abm_images
    end
    @image_ids = @images.collect{|image| image.id}.join(',')
    unless request.mobile?
      @abm_albums = AbmAlbum.find_my_albums_with_pagenate(current_base_user.id, AppResources[:dia][:entry_album_list_size])
    end
  end
  
  def update_confirm
    @diary = DiaEntry.find(params[:id]).dia_diary
    @dia_entry = DiaEntry.new(params[:dia_entry])
    @dia_entry.dia_diary_id = @diary.id
    @images = params[:images] ? AbmImage.find(params[:images].keys) : []
    
    unless @dia_entry.valid?
      render :action => 'edit'
      return
    end
    
    if params[:draft] != nil
      entry = DiaEntry.find(params[:id])
      entry.draft_flag = true
      entry.update_attributes(params[:dia_entry])
      entry.update_images(@images.collect{|image| image.id})
      
      redirect_to :action => 'draft_done'
    end
  end
  
  def update
    if cancel?
      @dia_entry = DiaEntry.new(params[:dia_entry])
      @images = params[:images] ? AbmImage.find(params[:images].keys) : []
      render :action => 'edit', :id => params[:id]
      return
    end
    
    @dia_entry = DiaEntry.find(params[:id])
    @dia_entry.attributes = params[:dia_entry]
    if @dia_entry.draft_flag
      @dia_entry.contributed_at = Time.now
      @dia_entry.draft_flag = false
    end
    
    unless @dia_entry.valid?
      @images = params[:images] ? AbmImage.find(params[:images].keys) : []
      @abm_albums = AbmAlbum.find_my_albums_with_pagenate(current_base_user.id, AppResources[:dia][:entry_album_list_size])
      render :action => 'edit'
      return
    end
    
    @dia_entry.save
    
    if params[:images]
      @dia_entry.update_images(params[:images].keys)
    else
      @dia_entry.update_images([])
    end
    
    flash[:notice] = t('view.flash.notice.dia_entry_update')
    if request.mobile?
      redirect_to :action => 'update_done', :id => @dia_entry.id
    else
      redirect_to :action => 'list'
    end
  end
  
  def update_done
    #render :layout => 'dia_done'
  end

  # Abm への領域侵犯っぽいけどちょっとここで作ってみるよ
  # 画像を選択する前段でアルバムを選択するための画面
  def album_list
    @albums = current_base_user.abm_albums.find(:all, :page => {:size => AppResources['abm']['album_list_size_mobile'], :current => params[:page]})    
    @type = params[:type]
    @entry_id = params[:entry]
    @back_url = url_for(:action => @type, :id => @entry_id)
    @image_ids = params[:images]
  end
  
  # Abm への領域侵犯っぽいけどちょっとここで作ってみるよ
  # 画像を選択するための画面
  def album_show
    @album = AbmAlbum.find(params[:id])
    
    @type = params[:type]
    @entry_id = params[:entry]
    @back_url = url_for(:action => 'album_list', :type => @type, :entry => @entry_id)
    
    @images = @album.abm_images.find(:all, :page => {:size => AppResources['abm']['image_list_size_mobile'], :current => params[:page]})    
    @image_ids = params[:images]
  end
  
  def add_images
    images = (params[:images])? params[:images].keys : []
    old_images = (params[:old_images].blank?)? [] : params[:old_images].split(',')
    images.concat(old_images).uniq!
    
    if images.empty?
      flash[:error] = "#{I18n.t('view.noun.abm_image')}を選択してください"
      redirect_to :action => :album_show, :id => params[:album_id], :entry => params[:entry], :type => params[:type]
    else
      redirect_to :action => params[:type], :id => params[:entry], :images => images.join(',')
    end  
  end
  
  def show
    order = params[:comment_order]
    order = "desc" if order.nil? || !(order =~ /^(desc|asc)$/)
    
    @entry = DiaEntry.find(params[:id])
    @diary = @entry.dia_diary
    @comments = @entry.dia_entry_comments.find(:all, :order => ["created_at #{order}"],
                                               :page => {:size => AppResources[:dia][:entry_comment_list_size_with_comment], :current => params[:page]})
    
    DiaEntryComment.to_read_if_entry_owner(current_base_user, @diary.base_user_id, @comments)
    
    unless request.mobile?
      @recent_dia_entries = @diary.accesible_entries(current_base_user).find(:all, :limit => AppResources[:dia][:recent_entry_list_size])
      @recent_dia_entry_comments = DiaEntryComment.accesible_comments(@diary, current_base_user).find(:all, :limit => AppResources[:dia][:recent_comment_list_size])
    end
  end
  
  def show_image
    @entry = DiaEntry.find(params[:id])
    @diary = @entry.dia_diary
    @image = AbmImage.find(params[:image])
  end
  
  def delete_confirm
    @entry = DiaEntry.find(params[:id])
    @diary = @entry.dia_diary
    @delete_action_name = @entry.draft_flag ? 'delete_draft' : 'delete'
  end
  
  def delete
    if cancel?
      cancel_to_return
      return
    end
    
    entry = DiaEntry.find(params[:id])
    entry.destroy
    
    flash[:notice] = t('view.flash.notice.dia_entry_delete')
    if request.mobile?
      redirect_to :action => 'delete_done'
    else
      redirect_to :action => 'list'
    end
  end
  
  def delete_draft
    if cancel?
      redirect_to :action => 'edit', :id => params[:id]
      return
    end
    
    entry = DiaEntry.find(params[:id])
    entry.destroy
    
    if request.mobile?
      redirect_to :action => 'draft_delete_done'
    else
      flash[:notice] = t('view.flash.notice.dia_entry_delete_draft')
      redirect_to :action => 'draft_list'
    end
  end
  
  def delete_done
  end
  
  def draft_delete_done
  end
  
private

  # params[:id] の id を持つ DiaEntry の所有者でなければエラーページに遷移
  def owner_only
    unless DiaEntry.find(params[:id]).mine?(current_base_user)
      redirect_to_error("U-04004")
      return false
    end
  end
  
  # params[:id] が nil であるか、params[:id] で指定される日記記事が存在しなかったらエラー
  def nil_check
    if params[:id] == nil
      redirect_to_error('U-04005')
      return false
    end
    
    if DiaEntry.find_by_id(params[:id]) == nil
      redirect_to_error('U-04005')
      return false
    end
  end

  # params[:id] で指定された id をもつ DiaEntry
  # params[:image] で指定された id をもつ AbmImage
  # が関連付けられていなければ（DiaEntriesAbmImage が存在しなければ）エラーページに遷移する
  # DiaEntry と AbmImage の所有者が同じかどうかも見たほうがいい？
  def entry_image_access_filter
    unless DiaEntriesAbmImage.find_by_dia_entry_id_and_abm_image_id(params[:id], params[:image])
      redirect_to_error('U-04006')
      return false
    end
  end
  
  # params[:images] でカンマ区切り文字列もしくは Hash.keys で指定された id をもつ
  # AbmImage（正確にはそれを内包する AbmAlbum）の所有者でなければエラーページに遷移
  def images_access_filter
    temp = params[:images]
    if temp
      if temp.is_a?(Hash)
        image_ids = temp.keys
      elsif temp.is_a?(String)
        image_ids = params[:images].split(/\s*,\s*/)
      end      
      images = AbmImage.find(image_ids)
      current_base_user_id = current_base_user.id
      for image in images
        unless image.abm_album.mine?(current_base_user_id)
          redirect_to_error('U-04007')
          return false
        end
      end
    end
  end
  
  # current_base_user がアクセス可能なフォトアルバムなら true
  def album_owner_only
    unless AbmAlbum.find(params[:id]).is_mine?(current_base_user_id)
      redirect_to_error("U-04008")
      return false
    end
  end
  
end
