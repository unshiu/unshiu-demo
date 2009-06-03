module ManageBaseErrorControllerModule

  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index 
    list
    render :action => 'list'
  end
  
  def list
    @base_errors = BaseError.find(:all, :page => {:size => 30, :current => params[:page]})
  end
  
  def edit
    @base_error = BaseError.find(params[:id])
  end

  def update_confirm
    @base_error = BaseError.new(params[:base_error])

    unless @base_error.valid?
      render :action => 'edit'
      return
    end
  end
  
  def update
    if cancel?
      @base_error = BaseError.new(params[:base_error])
      render :action => 'edit'
      return
    end
    
    base_error = BaseError.find(params[:id])
    base_error.update_attributes(params[:base_error])
    
    flash[:notice] = I18n.t('view.noun.base_error_code') + "を編集しました。"
    redirect_to :action => 'list'
  end
  
end