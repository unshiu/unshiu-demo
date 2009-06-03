
module AbmImageCommentControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        before_filter :access_filter, :only => ['comments']
        before_filter :deletable_filter, :only => ["delete_comment", "confirm_delete_comment"]

        nested_layout_with_done_layout
      end
    end
  end

  def comments
    
    @image = AbmImage.find(params[:id])
    @album = @image.abm_album
    @comments = @image.abm_image_comments.find(
                  :all,
                  :page => {
                    :size => AppResources["abm"]["image_comments_list_size"],
                    :current => params[:page]
                  }
                )
    
  end
  
  def new_comment
    @image = AbmImage.find(params[:id])
    @comment = AbmImageComment.new
  end
  
  def confirm_comment
    @image = AbmImage.find(params[:id])
    @comment = AbmImageComment.new(params[:comment])
    
    valid_check @comment, 'new_comment'
  end

  # 画像コメントをajaxで更新
  def update_remote
    @image = AbmImage.find(params[:id])
    @comment = AbmImageComment.new(params[:comment])
    @comment.attributes = {:abm_image_id => @image.id, :base_user_id => current_base_user.id}
    
    unless @comment.valid?
      render "update_remote_error"
      return
    end
    
    @comment.save
    @abm_image_comments = @image.abm_image_comments.recent(AppResources[:abm][:image_comments_list_size_for_abm_image])
  end
  
  # 画像コメントを保存
  def save_comment
    @image = AbmImage.find(params[:id])
    @comment = AbmImageComment.new(params[:comment])
    
    if cancel? 
      render :action => 'new_comment'
      return
    end
    
    unless @comment.valid?
      render :action => 'new_comment'
      return
    end
    
    @comment.abm_image_id = @image.id
    @comment.base_user_id = current_base_user.id
    @comment.save
    
    redirect_to :action => 'save_comment_done', :id => @image.id
  end

  # 画像コメントを保存完了
  def save_comment_done
    @image = AbmImage.find(params[:id])
  end
  
  # コメントの削除実行。
  # @commentが自分のものか自分の画像に付いているものなら削除可
  def delete_comment
    @comment = AbmImageComment.find(params[:id])
    
    if cancel?
      cancel_to_return
      return
    end
    
    @image = @comment.abm_image
    @comment.invisible_by(current_base_user_id)
    
    if request.mobile?
      redirect_to :action => 'delete_comment_done', :id => @comment.abm_image_id
    else
      redirect_to :controller => :abm_image, :action => :show, :id => @comment.abm_image_id
    end
  end

  def delete_comment_done
    @abm_image_id = params[:id]
  end
  
  def confirm_delete_comment
    @comment = AbmImageComment.find(params[:id])
    @image = @comment.abm_image
  end
  
  private

  def access_filter
    image = AbmImage.find(params[:id])
    album = image.abm_album
    owner_id = album.base_user_id
    public_level = album.public_level

    unless UserRelationSystem.accessible?(current_base_user, owner_id, public_level)
      if logged_in?
        redirect_to_error "U-02003"
      else
        redirect_to :controller => 'base_user', :action => 'login'
      end
      return false
    end
    return true
  end

  # params[:id] の id を持つ DiaEntryComment の削除権限（日記の所有者か，コメントを書いた人）がなければエラーページに遷移
  def deletable_filter
    comment = AbmImageComment.find(params[:id])
    unless comment.deletable?(current_base_user)
      redirect_to_error("U-02004")
    end
  end
  
  # objectにvalid?をかけて、falseならrender_actionをrenderする。
  def valid_check(object, render_action)
    
    unless object.valid?
      render :action =>  render_action
      return
    end
    
  end
end
