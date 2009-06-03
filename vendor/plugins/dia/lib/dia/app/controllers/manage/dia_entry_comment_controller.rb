module ManageDiaEntryCommentControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def list
    @comments = DiaEntryComment.find(:all, :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})    
  end
  
  def delete_confirm
    @comment = DiaEntryComment.find(params[:id])
  end
  
  def delete
    comment = DiaEntryComment.find(params[:id])
    
    if cancel?
      redirect_to :controller => 'manage/dia_entry', :action => 'show', :id => comment.dia_entry_id
      return
    end
    
    comment.invisible_by(current_base_user_id)
    flash[:notice] = "#{I18n.t('view.noun.dia_entry_comment')}「#{comment.body}」を削除しました。"
    redirect_to :controller => 'dia_entry', :action => 'show', :id => comment.dia_entry_id
  end
end
