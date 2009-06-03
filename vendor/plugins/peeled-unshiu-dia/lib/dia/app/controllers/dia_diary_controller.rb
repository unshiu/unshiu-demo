module DiaDiaryControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required
        
        nested_layout_with_done_layout
      end
    end
  end
  
  def edit
    @diary = get_diary
  end
  
  def update_confirm
    @diary = DiaDiary.new(params[:diary])
  end
  
  def update
    diary = get_diary
    
    if cancel?
      @diary = DiaDiary.new
      @diary.default_public_level = params[:diary][:default_public_level]
      render :action => 'edit'
      return
    end
    
    diary.default_public_level = params[:diary][:default_public_level]
    diary.save
    
    redirect_to :action => 'update_done'
  end
  
  def update_done
  end

end
