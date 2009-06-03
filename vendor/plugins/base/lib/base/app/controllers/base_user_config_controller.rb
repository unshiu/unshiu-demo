module BaseUserConfigControllerModule
  class << self
    def included(base)
      base.class_eval do
        before_filter :login_required, :except => ['mail_reset']
        before_filter :activation_code_check, :only => ['mail_reset']
        nested_layout_with_done_layout
      end
    end
  end
  
  def index
    @base_user = current_base_user
    @dia_diary = DiaDiary.find_or_create(current_base_user.id)
  end

  def __mobile_index
  end
  
  def edit
    @base_user = current_base_user
    @dia_diary = DiaDiary.find_or_create(current_base_user.id)
  end
  
  def update_confirm
    @base_user = BaseUser.new(params[:base_user])
    @dia_diary = DiaDiary.new(params[:dia_diary])
  end
  
  def update
    base_user = current_base_user
    dia_diary = DiaDiary.find_or_create(current_base_user.id)
    
    if cancel?
      @base_user = BaseUser.new(params[:base_user])
      @dia_diary = DiaDiary.new(params[:dia_diary])
      render :action => 'edit'
      return
    end
    
    base_user.update_attributes(params[:base_user])
    dia_diary.update_attributes(params[:dia_diary])
    
    if request.mobile?
      redirect_to :action => 'update_done'
    else
      flash[:notice] = t('view.flash.notice.base_user_config_update')
      redirect_to :action => 'index'
    end
  end
  
  def update_done
  end
  
  def uid_set_confirm
  end

  def uid_set
    user = current_base_user
    uid = request.mobile.ident
    
    unless uid
      flash[:error] = '端末IDを取得できませんでした。'
      redirect_to :action => 'uid_set_confirm'
      return
    end
    
    user.uid = uid
    user.save
    redirect_to :action => 'uid_set_done'
  end

  def uid_set_done
  end

  # 「メールアドレス変更しますか？」って表示しているページ
  def mail_reset_input
  end

  def mail_reset_confirm
    @new_mail_address = params[:new_mail_address]

    maf = Forms::BaseMailAddressResetForm.new
    maf.mail_address = @new_mail_address
    unless maf.valid?
      @maf = maf
      render :action => 'mail_reset_input'
      return
    end
  end

  # メールアドレス変更用URLをメールで送信する
  def mail_reset_send
    @new_mail_address = params[:new_mail_address]
    
    if cancel?
      render :action => 'mail_reset_input'
      return
    end
    
    @maf = Forms::BaseMailAddressResetForm.new(:mail_address => @new_mail_address)
    unless @maf.valid?
      render :action => 'mail_reset_input'
      return
    end
    
    user = current_base_user
    user.make_activation_code
    user.new_email = @new_mail_address
    user.save
    
    flash[:notice] = t('view.flash.notice.base_user_config_mail_reset_send')
    BaseMailerNotifier.deliver_mail_reset(user, :force)
    if request.mobile?
      redirect_to :action => 'mail_reset_send_done'
    else
      redirect_to :controller => 'base_user_config', :action => 'index'
    end
  end
  
  def mail_reset_send_done
  end

  # 新しいメールアドレスを有効にする
  def mail_reset
    user = BaseUser.find_by_activation_code(params[:id])
    
    other_user = BaseUser.find_by_email(user.new_email)
    if other_user
      if other_user.active? || other_user.forbidden?
        redirect_to_error('U-01019')
        return
      end
      
      # 仮登録ユーザーの場合は削除してしまう
      other_user.destroy
    end
    
    user.email = user.new_email
    user.new_email = nil
    user.make_activation_code # アクティベーションコードを無効にするため
    user.save
    
    setup_carrier(user)
    
    # ログイン状態にする
    self.current_base_user = user

    flash[:notice] = t('view.flash.notice.base_user_config_mail_reset')
    if request.mobile?
      redirect_to :action => 'mail_reset_done'
    else
      redirect_to :controller => 'base_user_config', :action => 'index'
    end
  end

  # メールアドレス変更完了
  def mail_reset_done
  end

  private
  def activation_code_check
    user = BaseUser.find_by_activation_code(params[:id])
    if user == nil || params[:id] == nil || user.new_email == nil
      redirect_to_error('U-01020')
      return false
    end
    return true
  end
end
