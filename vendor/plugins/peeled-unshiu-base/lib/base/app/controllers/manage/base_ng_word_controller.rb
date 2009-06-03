module ManageBaseNgWordControllerModule
  
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
    @ng_words = BaseNgWord.find(:all, :page => {:size => 30, :current => params[:page]})
  end
  
  def new
    @ng_word = BaseNgWord.new
    @ng_word.active_flag = true
  end

  def show
    @ng_word = BaseNgWord.find(params[:id])
  end
  
  def confirm
    @ng_word = BaseNgWord.new(params[:ng_word])
    
    unless @ng_word.valid?
      render :action => 'new'
      return
    end
  end
  
  def create
    params[:ng_word][:word].strip_with_full_size_space! # NGワードとして前後の空白は不要
    ng_word = BaseNgWord.new(params[:ng_word])    

    if cancel?
      @ng_word = ng_word
      render :action => 'new'
      return
    end
    
    ng_word.save
    
    flash[:notice] = "NGワードを新規作成しました。"
    redirect_to :action => 'list'
  end

  def edit
    @ng_word = BaseNgWord.find(params[:id])
  end

  def update_confirm
    @ng_word = BaseNgWord.find(params[:id])
    @ng_word.attributes = params[:ng_word]
    
    unless @ng_word.valid?
      render :action => 'edit'
      return
    end
  end
  
  def update
    if cancel?
      @ng_word = BaseNgWord.new(params[:ng_word])
      render :action => 'edit'
      return
    end
    
    ng_word = BaseNgWord.find(params[:id])
    ng_word.update_attributes(params[:ng_word])
    
    flash[:notice] = "NGワードを編集しました。"
    redirect_to :action => 'list'
  end
  
  def delete_confirm
    @ng_word = BaseNgWord.find(params[:id])    
  end
  
  def delete
    if cancel?
      redirect_to :action => 'show', :id => params[:id]
      return
    end
    
    BaseNgWord.destroy(params[:id])

    flash[:notice] = "NGワードを削除しました。"
    redirect_to :action => 'list'
  end
end
