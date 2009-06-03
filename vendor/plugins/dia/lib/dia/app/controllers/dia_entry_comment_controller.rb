module DiaEntryCommentControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required, :except => ["list"]
        before_filter :access_filter, :only => ["list", "new", "confirm", "create"]
        before_filter :owner_only, :only => ["delete_confirm", "delete"]
        
        nested_layout_with_done_layout
      end
    end
  end
  
  def list
    @entry = DiaEntry.find(params[:id])
    @diary = @entry.dia_diary
    key = Util.resources_keyname_from_device("entry_comment_list_size", request.mobile?)
    @comments = @entry.dia_entry_comments.find(:all, :page => {:size => AppResources["dia"][key], :current => params[:page]})
      
    DiaEntryComment.to_read_if_entry_owner(current_base_user, @diary.base_user_id, @comments)    
  end
  
  def new
    @entry = DiaEntry.find(params[:id])
    @diary = @entry.dia_diary    
    @comment = DiaEntryComment.new
  end
  
  def confirm
    @entry = DiaEntry.find(params[:id])
    @diary = @entry.dia_diary    
    @comment = DiaEntryComment.new(params[:comment])

    unless @comment.valid?
      render :action => 'new'
      return
    end
  end

  def create
    entry = DiaEntry.find(params[:id])
    comment = DiaEntryComment.new(params[:comment])
    comment.dia_entry_id = entry.id
    comment.base_user_id = current_base_user.id
    comment.read_flag = true if current_base_user.me?(entry.dia_diary.base_user_id) # 自分のコメントは最初から既読
    comment.save
    
    unless current_base_user.me?(entry.dia_diary.base_user_id)
      BaseMailerNotifier.deliver_notify_dia_entry_commented(entry, current_base_user)
    end
    
    redirect_to :action => 'done', :id => entry.id
  end
  
  def create_remote
    entry = DiaEntry.find(params[:id])
    @comment = DiaEntryComment.new(params[:comment])
    @comment.dia_entry_id = entry.id
    @comment.base_user_id = current_base_user.id
    @comment.read_flag = true if current_base_user.me?(entry.dia_diary.base_user_id) # 自分のコメントは最初から既読
    
    if @comment.save
      unless current_base_user.me?(entry.dia_diary.base_user_id)
        BaseMailerNotifier.deliver_notify_dia_entry_commented(entry, current_base_user)
      end
      @comments = entry.dia_entry_comments.find(:all, :limit => AppResources[:dia][:entry_comment_list_size_with_comment], :order => "created_at desc")
    else
      render "create_remote_error"
      return
    end
    
  end
  
  def done
    @entry = DiaEntry.find(params[:id])
    #@diary = @entry.dia_diary
  end
  
  def delete_confirm
    @comment = DiaEntryComment.find(params[:id])
    @entry = @comment.dia_entry
    @diary = @entry.dia_diary
  end
  
  def delete
    comment = DiaEntryComment.find(params[:id])
    
    if cancel?
      redirect_to :controller => :dia_entry, :action => :show, :id => comment.dia_entry_id
      return 
    end
    
    comment.invisible_by(current_base_user_id)
    
    flash[:notice] = t('view.flash.notice.dia_entry_comment_delete')
    if request.mobile?
      redirect_to :action => 'delete_done', :id => comment.dia_entry_id
    else
      redirect_to :controller => :dia_entry, :action => :show, :id => comment.dia_entry_id
    end
  end
  
  def delete_done
    @entry = DiaEntry.find(params[:id])
    #@diary = @entry.dia_diary
  end

private
  
  # params[:id] の id を持つ DiaEntryComment の削除権限（日記の所有者か，コメントを書いた人）がなければエラーページに遷移
  def owner_only
    comment = DiaEntryComment.find(params[:id])
    unless comment.deletable?(current_base_user)
      redirect_to_error("U-04002")
    end
  end
  
end
