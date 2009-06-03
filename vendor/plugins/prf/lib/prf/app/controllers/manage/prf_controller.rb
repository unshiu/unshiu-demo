module ManagePrfControllerModule

  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    default_question_set = PrfQuestionSet.find_basic_profile
    @questions = default_question_set.prf_question_set_partials.find(:all, :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end
  
  def new
    @question = PrfQuestion.new(
        :body => '',
        :question_type => PrfQuestion::QUESTION_TYPE_RADIO,
        :active_flag => true)
  end
  
  def confirm
    @question = PrfQuestion.new(params[:question])
    @question.prf_profile_id = 0
    @question.open_accept_type = 0
    
    unless @question.valid?
      render :action => :new
      return
    end
  end
  
  def create
    @question = PrfQuestion.new(params[:question])
    @question.prf_profile_id = 0
    @question.open_accept_type = 0
    
    if cancel?
      render :action => :new
      return
    end
    
    @question.save

    PrfQuestionSetPartial.create(:prf_question_id => @question.id,
                                 :prf_question_set_id => PrfQuestionSet::KIND_BASIC_ID,
                                 :required_flag => false,
                                 :order_num => @question.id)
                                 
    
    if (@question.question_type == PrfQuestion::QUESTION_TYPE_RADIO ||
        @question.question_type == PrfQuestion::QUESTION_TYPE_SELECT ||
        @question.question_type == PrfQuestion::QUESTION_TYPE_CHECKBOX)
        
      flash[:notice] = t('view.flash.notice.prf_create_with_choice')
      redirect_to :action => "choices", :id => @question.id
    else 
      flash[:notice] = t('view.flash.notice.prf_create')
      redirect_to :action => "index"
    end
  end
  
  def create_choice_confirm
    @question = PrfQuestion.find(params[:id])
    
    add_flag = false
    @choices = []
    params[:choice].each do |c|
      choice = PrfChoice.new(c)
      choice.attributes = {:prf_profile_id => 0, :prf_question_id => @question.id }
      unless choice.free_area_type
        choice.free_area_type = PrfChoice::CHOICE_FREE_AREA_TYPE_NONE
      end
      
      if choice.valid?
        add_flag = true
      end
      @choices << choice
    end
    
    unless add_flag
      flash.now[:error] = t('view.flash.error.prf_choice_create')
      render :action => :choices
      return
    end
  end
  
  def create_choice
    @question = PrfQuestion.find(params[:id])
    
    @choices = []
    params[:choice].each do |c|
      choice = PrfChoice.new(c)
      choice.attributes = {:prf_profile_id => 0, :prf_question_id => @question.id }
      unless choice.free_area_type
        choice.free_area_type = PrfChoice::CHOICE_FREE_AREA_TYPE_NONE
      end
      @choices << choice
    end
    
    if cancel?
      render :action => :choices
      return
    end
    
    @choices.each do |choice| # キャンセルされた後に入力内容を保持するため
      choice.save
    end
  
    flash[:notice] = t('view.flash.notice.prf_choice_create')
    redirect_to :action => "choices", :id => @question.id 
  end
  
  def edit
    @question = PrfQuestion.find(params[:id])
  end
  
  def edit_confirm
    id = params[:id]
    @question = PrfQuestion.new(params[:question])
    unless @question.valid?
      render :action => :edit
    end
    @question.id = id
  end
  
  def edit_complete
    @question = PrfQuestion.find(params[:id])
    q2 = PrfQuestion.new(params[:question])
    unless q2.selectable?
      @question.prf_choices.each do |choice|
        choice.destroy
      end
    end
    
    @question.body = q2.body
    @question.active_flag = q2.active_flag
    @question.question_type = q2.question_type
    
    if cancel?
      render :action => :edit
      return
    end
    
    @question.save
    
    flash[:notice] = t('view.flash.notice.prf_question_update')
    redirect_to :action => 'index'
  end
  
  def edit_choice
    @prf_choice = PrfChoice.find(params[:id])
    @prf_question = @prf_choice.prf_question
  end
  
  def edit_choice_confirm
    @prf_question = PrfChoice.find(params[:prf_choice][:id]).prf_question
    @prf_choice = PrfChoice.new(params[:prf_choice])
    @prf_choice.id = params[:prf_choice][:id]
    unless @prf_choice.valid?
      render :action => :edit_choice
    end
  end
  
  def edit_choice_update
    @prf_choice = PrfChoice.find(params[:id])
    @prf_choice.attributes = params[:prf_choice]
    
    if cancel?
      @prf_question = @prf_choice.prf_question
      render :action => :edit_choice
      return
    end
    
    if @prf_choice.save
      flash[:notice] = t('view.flash.notice.prf_choice_update')
      redirect_to :action => 'choices', :id => @prf_choice.prf_question.id
    else
      redirect_to :action => 'edit_choice', :id => @prf_choice.id
    end
  end
  
  def choices
    question_id = params[:id]
    @question = PrfQuestion.find(question_id)
    
    if @question
      @choices = []
      5.times do |i|
        @choices << PrfChoice.new(:prf_question_id => question_id, :body => '', :free_area_type => PrfChoice::CHOICE_FREE_AREA_TYPE_NONE)
      end
    else
      redirect_to :action => 'new'
    end
  end
  
  # 質問を消す
  def delete_question_confirm
    @question = PrfQuestion.find(params[:id])
  end
  
  def delete_question_complete
    question = PrfQuestion.find(params[:id])
    
    if cancel?
      redirect_to :action => :choices, :id => question.id
      return
    end
    
    question.destroy
    flash[:notice] = t('view.flash.notice.prf_question_delete')
    redirect_to :action => 'index'
  end
  
  # 質問を上下する
  def move_question
    num = params[:num].to_i
    type = params[:type].to_i
    default_partials = PrfQuestionSet.find_basic_profile.prf_question_set_partials
    if num < 0 || (num > default_partials.size - 1) ||
        (num == 0 && type == -1) || (num == default_partials.size - 1 && type == 1)
      redirect_to_error "M-08001"
      return
    end
    
    default_partials[num], default_partials[num + type] = default_partials[num + type], default_partials[num]
    order_num = 0
    default_partials.each do |partial|
      partial.order_num = order_num
      partial.save
      order_num += 1
    end
    redirect_to :action => 'index'
  end
  
  # 選択肢を消す
  def delete_choice_confirm
    @choice = PrfChoice.find(params[:id])
  end
  
  def delete_choice_complete
    choice = PrfChoice.find(params[:id])
    
    if cancel?
      redirect_to :action => :choices, :id => choice.prf_question_id
      return
    end
    
    choice.destroy
    flash[:notice] = t('view.flash.notice.prf_choice_delete')
    redirect_to :action => 'choices', :id => choice.prf_question_id
  end
end
