module ManageAbmImageCommentControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def delete_confirm
    @comment = AbmImageComment.find(params[:id])
  end
  
  def delete
    comment = AbmImageComment.find(params[:id])
    
    if cancel?
      redirect_to :controller => 'manage/abm_image', :action => 'show', :id => comment.abm_image_id
      return
    end
    
    comment.invisible_by(current_base_user_id)
    flash[:notice] = "#{I18n.t('view.noun.abm_image_comment')}を削除しました。"
    redirect_to :controller => 'abm_image', :action => 'show', :id => comment.abm_image_id
  end
end
