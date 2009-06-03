module BaseNoticeControllerModule
  class << self
    def included(base)
      base.class_eval do
        nested_layout_with_done_layout
      end
    end
  end
  
  def list
    @notices = BaseNotice.all_notices(:page => {:size => AppResources['base']['notice_list_size'], :current => params[:page]})
  end

  def show
    @notice = BaseNotice.find(params[:id])
  end
end
