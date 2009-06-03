module PrfControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required, :except => 'show'
        nested_layout_with_done_layout
      end
    end
  end
  
  def index
    redirect_to :action => :show, :id => current_base_user.id
  end

  def show
    @user = BaseUser.find(params[:id])
    
    @entries = DiaDiary.find_or_create(@user).accesible_entries(current_base_user).find(:all, :page => {:size => AppResources['dia']['profile_entry_list_size']})
    @albums = AbmAlbum.find_accessible_albums(current_base_user, @user.id, :order => "updated_at desc", 
                                              :page => {:size => AppResources['abm']['profile_album_list_size']})
    @question_set = default_question_set
    check_and_create_user(@user.id)
  end
  
  def mail
    @mail_address = BaseMailerNotifier.mail_address(current_base_user.id, "PrfProfile", "receive", current_profile.id)
  end
  
  def edit
    @prf_profile = PrfProfile.find_by_base_user_id(current_base_user.id)
    @question_set = default_question_set
  end
  
  def confirm
    prf_answers = setup_new_answers
    # validation
    @profile = PrfProfile.new
    
    unless @profile.valid_with_answers?(prf_answers)
      render :action => 'edit'
      return
    end
  end

  def update
    answers = params[:q]
    comments = params[:c]
    
    if cancel?
      setup_new_answers
      render :action => 'edit'
      return
    end
    
    question_set = default_question_set
    
    question_set.prf_question_set_partials.each do |qs|
      question = qs.prf_question
      answer = answers[question.id.to_s]
      comment = comments[question.id.to_s] if comments
      if question.type_radio? || question.type_select?
        # 択一の場合
        body = comment.nil? ? '' : (comment[answer.to_s] || '')
        
        save_one_answer(question, answer, body)
      elsif question.type_checkbox?
        # 複数選択の場合
        save_some_answers(question, answer, comment)
      elsif question.type_text? || question.type_textarea?
        # 自由入力の場合
        save_text_answer(question, answer)
      end
    end
    
    # updated_at を更新させるのと、全文検索用のものを更新させるため
    current_profile.save
    current_profile.update_index(true)
    
    if params[:prf_profile]
      prf_profile = PrfProfile.find_by_base_user_id(current_base_user.id)
      prf_profile.public_level = params[:prf_profile][:public_level]
      prf_profile.save
    end
    
    flash[:notice] = t('view.flash.notice.prf_update')
    if request.mobile?
      redirect_to :action => 'done'
    else
      redirect_to :action => 'show', :id => current_base_user.id
    end
  end
  
  def done
  end

  def public_level_edit
    @prf_profile = PrfProfile.find_by_base_user_id(current_base_user.id)
  end
  
  def public_level_confirm
    @prf_profile = PrfProfile.find_by_base_user_id(current_base_user.id)
    @prf_profile.public_level = params[:prf_profile][:public_level]
  end
  
  def public_level_update
    @prf_profile = PrfProfile.find_by_base_user_id(current_base_user.id)
    @prf_profile.public_level = params[:prf_profile][:public_level]
    
    if cancel?
      render :action => 'public_level_edit'
      return
    end
    
    if @prf_profile.save
      flash[:notice] = "公開レベルを更新しました。"
      redirect_to :action => 'done'
    else
      @flash[:error] = "公開レベルの設定ができませんでした。"
      render :action => 'edit'
    end
  end
  
  def image
    @prf_profile = PrfProfile.find_by_base_user_id(current_base_user_id)
  end
  
  def image_upload
    @prf_profile = PrfProfile.find_by_base_user_id(current_base_user_id)
    @prf_image = @prf_profile.prf_image
    @prf_image = PrfImage.new(:prf_profile_id => @prf_profile.id) unless @prf_image
    @prf_image.image = params[:upload_file][:image]
    
    unless @prf_image.valid?
      flash.now[:error] = t('view.flash.error.prf_profile_image_update')
      render :action => :image
      return
    end
    @prf_image.save
    
    flash[:notice] = t('view.flash.notice.prf_profile_image_update')
    redirect_to :action => :show, :id => @prf_profile.base_user_id
  end
  
private
  
  def save_text_answer(question, text)
    # 自由記述の場合
    answer = PrfAnswer.find_by_prf_profile_id_and_prf_question_id(current_profile.id, question.id)
    body = text || ''
    if answer && answer.body == body
    else
      answer = PrfAnswer.new(:prf_profile_id => current_profile.id, :prf_question_id => question.id, :prf_choice_id => 0) unless answer
      answer.body = body
      answer.save
    end
  end
  
  def save_some_answers(question, answers, comments)
    add_list = []
    upd_list = []
    now_answer_hash = {}
    current_profile.answers(question.id).each do |a|
      now_answer_hash.store(a.prf_choice_id, a)
    end
    # 新しい回答をまわす
    if !answers.nil? && answers.size > 0
      question.prf_choices.map{|c| c.id }.each do |pick|
        if now_answer_hash.key?(pick) && answers.key?(pick.to_s)
          # 今までの回答にも新しい回答にも存在したら、それはあとでupdateするlistに入れる
          upd_list.push(now_answer_hash[pick])
          # 現在の回答一覧から削除
          now_answer_hash.delete(pick)
        elsif now_answer_hash.key?(pick) && !answers.key?(pick.to_s)
          # 今までの回答にあって、新しい回答になければ、削除
          # でもここでは削除しないで、ちょっと下の updateもinsertもしない～ のところで消す
        elsif !now_answer_hash.key?(pick) && answers.key?(pick.to_s)
          # 今までの回答になくて、新しい回答にあれば、追加
          add_list.push(pick)
        end
      end
    end

    # updateもinsertもしない「現在の回答」は全て削除する
    now_answer_hash.each_value do |now_ans|
      now_ans.destroy
    end
    
    # updateする回答
    upd_list.each do |answer|
      choice = PrfChoice.find(answer.prf_choice_id)
      if choice && choice.prf_question_id == question.id
        if choice.has_free_area?
          if comments
            comment = comments[choice.id.to_s] || ""
          else
            comment = ""
          end
          if answer.body == comment
          else
            answer.body = comment
            answer.save
          end
        end
      else
        answer.destroy
      end
    end
    
    # insertする回答
    add_list.each do |choice_id|
      choice = PrfChoice.find(choice_id)
      if choice && choice.prf_question_id == question.id
        answer = PrfAnswer.new(:prf_question_id => question.id,
          :prf_profile_id => current_profile.id,
          :prf_choice_id => choice.id,
          :body => '')
        if choice.has_free_area?
          body = comments[choice.id.to_s] || ""
          answer.body = body
        end
        answer.save
      end
    end
  end

  def save_one_answer(question, answer, body)
    choice_id = answer.to_i
    if choice_id > 0
      choice = PrfChoice.find(choice_id)
      if choice.prf_question_id == question.id
        prf_answer = PrfAnswer.find_by_prf_profile_id_and_prf_question_id(current_profile.id, question.id)
        if !prf_answer
          prf_answer = PrfAnswer.new(:prf_profile_id => current_profile.id,
            :prf_question_id => question.id)
        end
        prf_answer.prf_choice_id = choice.id
        if question.type_radio? && choice.has_free_area?
        else
          body = ''
        end
        prf_answer.body = body
        prf_answer.save
      end
    end
  end

  def current_profile
    PrfProfile.find_by_base_user_id(current_base_user.id)
  end

  def check_and_create_user(id)
    profile = PrfProfile.find_by_base_user_id(id)
    if !profile
      user = BaseUser.find(id)
      if user
        profile = PrfProfile.new_default_profile(:base_user_id => id)
        profile.save!
      end
    end
  end
  
  def default_question_set
    return PrfQuestionSet.find_basic_profile
  end

  def setup_new_answers
    answers = params[:q]
    comments = params[:c]
    question_set = default_question_set
    prf_answers = []
    
    # 入力されたものを validatoin のために PrfAnswer にしてみる
    # save, update は一切なし
    question_set.prf_question_set_partials.each do |qs|
      question = qs.prf_question
      answer = answers[question.id.to_s]
      comment = comments[question.id.to_s] if comments
      if question.type_radio? || question.type_select?
        # 択一の場合
        body = comment.nil? ? '' : (comment[answer.to_s] || '')
        
        prf_answer = PrfAnswer.new
        prf_answer.prf_question_id = question.id
        prf_answer.prf_choice_id = answer
        prf_answer.body = body
        prf_answers << prf_answer
      elsif question.type_checkbox?
        # 複数選択の場合
        checkes = (answer)? answer.keys : []
        for answer in checkes
          prf_answer = PrfAnswer.new
          prf_answer.prf_question_id = question.id
          prf_answer.prf_choice_id = answer
          prf_answer.body = comment[answer]
          prf_answers << prf_answer
        end
      elsif question.type_text? || question.type_textarea?
        # 自由入力の場合
        prf_answer = PrfAnswer.new
        prf_answer.prf_question_id = question.id
        prf_answer.body = answer
        prf_answers << prf_answer
      end
    end
    
    # ビュー用
    @question_set = default_question_set
    @new_answers = {}
    for prf_answer in prf_answers
      if prf_answer.prf_question.type_checkbox?
        @new_answers[prf_answer.prf_question_id] = [] unless @new_answers[prf_answer.prf_question_id]
        @new_answers[prf_answer.prf_question_id] << prf_answer
      else
        @new_answers[prf_answer.prf_question_id] = prf_answer
      end
    end
    
    prf_answers
  end
  
end
