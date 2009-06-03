module DiaControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        include UserRelationSystem
      end
    end
  end
  
  private
  # 日記を取得する
  # FIXME get_はrailsっぽくない
  # _return_:: id = params[:id] の DiaDiary、もしくは、ログインしているユーザーの DiaDiary を返す。params[:id] == nil、かつ、非ログインなら nil を返す
  def get_diary
    if params[:id]
      diary = DiaDiary.find_or_create(params[:id])
    elsif logged_in?
      diary = DiaDiary.find_or_create(current_base_user.id)
    else
      diary = nil
    end
    return diary
  end
  
  # アクセスしてきたユーザーが閲覧可能な日記記事(params[:id]指定)なら true、それ以外なら false を返す
  # before_filter で利用する
  def access_filter
    entry = DiaEntry.find(params[:id])
    
    if entry.draft_flag || !accessible?(entry.dia_diary.base_user_id, entry.public_level)
      if logged_in?
        redirect_to_error "U-04001"
      else
        redirect_to :controller => 'base_user', :action => 'login'
      end
      return false
    end
    return true
  end
  
end