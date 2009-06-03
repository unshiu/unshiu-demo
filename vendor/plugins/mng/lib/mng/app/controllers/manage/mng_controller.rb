#
# 管理画面トップ
#
module ManageMngControllerModule
  
  class << self
    def included(base)
     base.class_eval do
     end
    end
  end
   
  def index
    @system = MngSystem.new
  end
   
  def logout
    self.current_base_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "ログアウトしました。"
    redirect_back_or_default(:controller => 'manage/mng', :action => 'index')
  end
  
end
