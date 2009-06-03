module BaseSignupControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :activation_code_check, :only => ["ask_agreement", "__mobile_ask_agreement", "ask_names", "confirm", "signup"]
        before_filter :logged_in_or_activation_code_check, :only => ["password_set_ask", "password_set"]
        before_filter :login_required, :only => ['quit_confirm', 'quit']
        before_filter :manager_injunct, :only => ['quit_confirm', 'quit']
        
        nested_layout_with_done_layout
      end
    end
  end
  
  def presignup
    @base_mail_address_form = Forms::BaseMailAddressForm.new
  end
  
  def __mobile_presignup
    @resistration_mail_address = AppResources["base"]["registration_mail_address"]
  end

  def mail_regist
    @base_mail_address_form = Forms::BaseMailAddressForm.new(params[:base_mail_address_form])
    unless @base_mail_address_form.valid?
      render :action => :presignup
      return
    end
    
    @base_user = BaseUser.create_temporary_user_from_email(@base_mail_address_form.mail_address)
    if @base_user
      if !@base_user.active? && !@base_user.forbidden?
        BaseMailerNotifier.deliver_send_registration_url(@base_user, :force)
        flash[:notice] = t('view.flash.notice.base_signup_mail_regist')
        redirect_to :controller => 'base', :action => 'index'
        return
      end
    end
    flash.now[:error] = t('view.flash.error.base_signup_mail_registed')
    render :action => :presignup
  end
  
  def ask_agreement
    @activation_code = params[:id]
    @invite = params[:invite]
    @user =  BaseUser.find_by_activation_code(@activation_code)
    @user.receive_mail_magazine_flag = true
  end
  
  def __mobile_ask_agreement    
  end

  def ask_names
    if cancel?
      redirect_to :controller => 'base', :action => 'index'
      return
    end    
    
    @user =  BaseUser.find_by_activation_code(params[:id])
    @user.receive_mail_magazine_flag = true
  end

  def confirm
    @user = BaseUser.find_by_activation_code(params[:id])
    @user.password = params[:user][:password]
    @user.receive_mail_magazine_flag = params[:user][:receive_mail_magazine_flag]
    @user.login = params[:user][:login]
    @user.crypted_password = nil # パスワードの validation を行うため
    @user.status = BaseUser::STATUS_ACTIVE # パスワードの validation を行うため

    unless @user.valid? 
      @user.password = nil # パスワードはクリア
      render :action => 'ask_names'
      return
    end
  end

  def signup
    if cancel?
      @user =  BaseUser.new(params[:user])
      @user.password = nil # パスワードはクリア
      render :action => 'ask_names'
      return
    end
    
    @user = BaseUser.find_by_activation_code(params[:id])
    @user.attributes = params[:user]
    @user.crypted_password = nil # パスワードの validation を行うため
    @user.status = BaseUser::STATUS_ACTIVE # パスワードの validation を行うため
    
    unless @user.valid?
      @activation_code = params[:id]
      @invite = params[:invite]
      render :action => 'ask_agreement'
      return 
    end
    
    @user.activate(params[:user][:password], params[:user][:receive_mail_magazine_flag])
    BaseProfile.create(:base_user_id => @user.id)
    BaseMailerNotifier.deliver_send_complete_registration(@user)
    
    # 招待した人がいる場合は、その人と友だちにする
    if params[:invite]
      inviter = BaseUser.find_by_id(params[:invite])
      if inviter
        BaseFriend.add(@user.id, inviter.id)
        BaseFriend.add(inviter.id, @user.id)
      end
    end

    # ログイン状態にする
    self.current_base_user = @user
    
    flash[:notice] = I18n.t('view.noun.thanks_for_signing_up')
    redirect_back_or_default(:controller => 'base', :action => 'portal')
  end
  
  def quit_confirm
  end

  def quit
    user = current_base_user
    user.quitted_at = Time.now
    user.status = BaseUser::STATUS_WITHDRAWAL
    user.save
    user.destroy
    reset_session
    
    if request.mobile?
      redirect_to :action => 'quit_done'
    else
      flash[:notice] = t('view.flash.notice.base_signup_quit')
      redirect_to :controller => 'base', :action => 'index'
    end
  end
  
  def quit_done
  end
  
  def password_remind_ask
  end

  def password_remind_confirm
    @mail_address = params[:mail_address]

    maf = Forms::BasePasswordRemindForm.new
    maf.mail_address = @mail_address
    unless maf.valid?
      @maf = maf
      render :action => 'password_remind_ask'
      return
    end
  end
  
  def password_remind
    if cancel?
      @mail_address = params[:mail_address]
      render :action => 'password_remind_ask'
      return
    end
    
    @maf = Forms::BasePasswordRemindForm.new({:mail_address => params[:mail_address]})
    unless @maf.valid?
      render :action => 'password_remind_ask'
      return
    end
    
    user = BaseUser.find_by_email(params[:mail_address])
    return unless user
    
    user.make_activation_code
    if user.save
      flash[:notice] = t('view.flash.notice.password_remind')
      BaseMailerNotifier.deliver_password_remind(user, :force)
    else
      flash[:error] = t('view.flash.error.password_remind')
    end
    
    if request.mobile?
      redirect_to :action => 'password_remind_done'
    else
      redirect_to :controller => 'base', :action => 'index'
    end
  end
  
  def password_remind_done
  end

  def password_set_ask
  end
  
  def password_set
    if logged_in?
      user = current_base_user
    else
      user = BaseUser.find_by_activation_code(params[:id])
    end
    
    user.crypted_password = nil
    user.password = params[:password]
    
    unless user.valid?
      @user = user
      render :action => 'password_set_ask', :id => user.activation_code
      return
    end
    
    user.make_activation_code # アクティベーションコードを無効にするため
    user.save

    # ログイン状態にする
    self.current_base_user = user
    
    if request.mobile?
      redirect_to :action => 'password_set_done'
    else
      flash[:notice] = t('view.flash.notice.password_set')
      redirect_to :controller => 'base_user_config', :action => 'index'
    end
  end
  
  def password_set_done
  end

private

  def activation_code_check
    user = BaseUser.find_by_activation_code(params[:id])
    if user == nil || params[:id] == nil
      redirect_to_error("U-01018")
      return false
    end
    return true
  end
  
  # ログインしているか、正しいアクティベーションコードでなければエラー
  def logged_in_or_activation_code_check
    if logged_in?
      return true
    end
    
    user = BaseUser.find_by_activation_code(params[:id])
    if user == nil || params[:id] == nil
      redirect_to_error("U-01018")
      return false
    end
    return true
  end
  
  # 管理者の処理をはじく
  def manager_injunct
    unless BaseUserRole.manager?(current_base_user).nil?
      redirect_to_error("U-01022")
      return false
    end
    return true
  end
end