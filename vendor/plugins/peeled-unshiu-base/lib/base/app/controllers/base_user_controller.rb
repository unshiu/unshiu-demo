module BaseUserControllerModule
  class << self
    def included(base)
      base.class_eval do
        # If you want "remember me" functionality, add this before_filter to Application Controller
        before_filter :login_from_cookie
        
        nested_layout_with_done_layout
      end
    end
  end
  
  # say something nice, you goof!  something sweet.
  def index
    #redirect_to(:action => 'signup') unless logged_in? || BaseUser.count > 0
    unless BaseUser.count > 0
      redirect_to(:controller => '/base_signup', :action => 'presignup')
      return
    end
    
    if logged_in?
      redirect_to(:controller => 'base', :action => 'portal')
    else
      redirect_to(:action => 'login')
    end
  end
  
  # pnt_filter_title:ログイン
  def login
    return unless request.post?
      
    self.current_base_user = BaseUser.authenticate(params[:login], params[:password])
    if logged_in? && self.current_base_user.active?
      if params[:remember_me] == "1"
        self.current_base_user.remember_me
        cookies[:auth_token] = { :value => self.current_base_user.remember_token , :expires => self.current_base_user.remember_token_expires_at }
      end
      setup_carrier(current_base_user)
      
      redirect_back_or_default(:controller => '/base', :action => 'portal')
    else
      @base_login_form = Forms::BaseLoginForm.new
      @base_login_form.login = params[:login]
      @base_login_form.password = params[:password]
      @base_login_form.valid? # FIXME 構造的におかしいが #423とのかねあいでログイン処理前にチェックできない。 #423が解決したら修正する
      
      flash.now[:error] = 'ログインに失敗しました。'
      render :action => 'login'
    end
  end
  
  # かんたんログイン
  # pnt_filter_title:かんたんログイン
  def simple_login
    unless request.post?
      redirect_to :action => 'login'
      return
    end
    uid = request.mobile.ident
    if uid.blank?
      flash[:error] = '端末IDが取得できません。'
      redirect_to :action => 'login'
      return
    end
    
    self.current_base_user = BaseUser.authenticate_by_uid(uid)
    if logged_in? && self.current_base_user.active?
      if params[:remember_me] == "1"
        self.current_base_user.remember_me
        cookies[:auth_token] = { :value => self.current_base_user.remember_token , :expires => self.current_base_user.remember_token_expires_at }
      end
      setup_carrier(current_base_user)
      redirect_back_or_default(:controller => '/base', :action => 'portal')
    else
      flash[:error] = 'ログインに失敗しました。'
      redirect_to :action => 'login'
    end
  end
  
  def logout
    self.current_base_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "ログアウトしました。"
    redirect_back_or_default(:controller => '/base', :action => 'index')
  end
  
  # ユーザー検索
  def search
  end
  
  # 新着ユーザー一覧
  def list
    # ユーザ情報
    @user_info = Hash.new
    @user_info[:status] = [BaseUser::STATUS_ACTIVE]
    
    # プロフィール情報
    @profile_info = Hash.new
    unless params[:name].nil?
      @profile_info[:name] = params[:name].strip
      @profile_info[:name_public_level] = [UserRelationSystem::PUBLIC_LEVEL_ALL]
    end
    unless params[:area].blank?
      @profile_info[:area] = [params[:area]]
      @profile_info[:area_public_level] = [UserRelationSystem::PUBLIC_LEVEL_ALL]
    end
    unless params[:sex].nil?
      @profile_info[:sex] = params[:sex].keys 
      @profile_info[:sex_public_level] = [UserRelationSystem::PUBLIC_LEVEL_ALL]
    end
    unless params[:civil_status].nil?
      @profile_info[:civil_status] = params[:civil_status].keys
      @profile_info[:civil_status_public_level] = [UserRelationSystem::PUBLIC_LEVEL_ALL]
    end
    if params[:age]
      if !params[:age][:start].blank? || !params[:age][:end].blank?
        @profile_info[:birthday_public_level] = [UserRelationSystem::PUBLIC_LEVEL_ALL]
      end
      @profile_info[:age_start] = params[:age][:start].to_i unless params[:age][:start].blank?
      @profile_info[:age_end] = params[:age][:end].to_i unless params[:age][:end].blank?
    end
    
    @users = BaseUser.find_users_by_all_search_info(@user_info, @profile_info, @point_info,
              {:limit => 100, :page => {:size => AppResources['base']['user_list_size'], :current => params[:page]}, :order => 'joined_at desc'})
  end
  
private 
  
  def development_allowed
    unless development?
      redirect_to_error('U-01021')
      return
    end
  end
end
