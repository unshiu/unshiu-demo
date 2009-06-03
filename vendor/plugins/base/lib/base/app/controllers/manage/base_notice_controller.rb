module ManageBaseNoticeControllerModule
  class << self
    def included(base)
      base.class_eval do
        # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
        verify :method => :post, :only => [ :destroy, :create, :update ],
               :redirect_to => { :action => :list }
      end
    end
  end
  
  def index
    list
    render :action => 'list'
  end

  def list
    @notices = BaseNotice.find(:all,
      :order => 'start_datetime desc',
      :page => {:size => AppResources['mng']['standard_list_size'], :current => params[:page]})
  end

  def show
    @base_notice = BaseNotice.find(params[:id])
  end

  def new
    @base_notice = BaseNotice.new
    today = Date.today
    @base_notice.start_datetime = Time.local(today.year, today.month, today.day, 0, 0, 0)
    @base_notice.end_datetime = Time.local(today.year, today.month, today.day, 23, 59, 59)
  end

  def confirm
    @base_notice = BaseNotice.new(params[:base_notice])
    
    unless @base_notice.valid?
      render :action => 'new'
      return
    end
  end

  def create
    @base_notice = BaseNotice.new(params[:base_notice])

    if cancel?
      render :action => 'new'
      return
    end
    
    @base_notice.save
    
    flash[:notice] = 'お知らせを作成しました。'
    redirect_to :action => 'list'
  end

  def edit
    @base_notice = BaseNotice.find(params[:id])
  end

  def update_confirm
    @base_notice = BaseNotice.new(params[:base_notice])
    
    unless @base_notice.valid?
      render :action => 'edit'
      return
    end
  end
  
  def update
    if cancel?
      @base_notice = BaseNotice.new(params[:base_notice])
      render :action => 'edit'
      return
    end
    
    @base_notice = BaseNotice.find(params[:id])
    if @base_notice.update_attributes(params[:base_notice])
      flash[:notice] = 'お知らせを編集しました。'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def delete_confirm
    @base_notice = BaseNotice.find(params[:id])
  end
  
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    
    BaseNotice.find(params[:id]).destroy
      flash[:notice] = 'お知らせを削除しました。'
    redirect_to :action => 'list'
  end
end
