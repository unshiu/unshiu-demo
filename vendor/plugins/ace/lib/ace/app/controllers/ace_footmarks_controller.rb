module AceFootmarksControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        nested_layout_with_done_layout
      end
    end
  end
  
  def index
    @footmarks = AceFootmark.find(:all, :conditions => ['footmarked_user_id = ?', current_base_user_id], :order => 'updated_at desc',
                                  :page => {:size => AppResources[:ace][:footmark_list_size], :current => params[:page]})
  end
  
end
