#
# 管理者画面：メールマガジン配信管理
#
module ManageMlgDeliveryControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # 配信設定
  # _param1_:: params[:id] マガジンID
  def setup
    @mlg_magazine = MlgMagazine.find(params[:id])
    provide_setup_show
  end
  
  # 配信設定　確認ページ
  def confirm
    @mlg_magazine = MlgMagazine.find(params[:mlg_magazine][:id])
    @mlg_magazine.attributes = params[:mlg_magazine]
    
    validate_date(@mlg_magazine, params[:mlg_magazine], 'send_at')
    
    unless @mlg_magazine.errors.empty?
      provide_setup_show
      render :action => 'setup'
      return
    end
    
    @pnt_master = PntMaster.find(params[:pnt_master][:id])
    
    # ユーザ情報
    @user_info = Hash.new
    @user_info[:receive_mail_magazine_flag] = [true] if params[:receive_mail_magazine_flag]
    unless params[:base_carrier_id].nil?
      @user_info[:base_carrier_id] = params[:base_carrier_id].keys
      @carriers = BaseCarrier.find(@user_info[:base_carrier_id])
    end
    joined_at = params[:joined_at]
    unless joined_at['start(1i)'].blank?
      unless validate_date(nil, joined_at, 'start')
        flash[:error] = "#{I18n.t('activerecord.attributes.base_user.joined_at')}の開始日が正しくありません。"
        redirect_to :action => 'setup', :id => @mlg_magazine.id
        return
      end
      @user_info[:joined_at_start] = joined_at['start(1i)'] + '-' + joined_at['start(2i)'] + '-' + joined_at['start(3i)'] 
    end
    unless joined_at['end(1i)'].blank?
      unless validate_date(nil, joined_at, 'end')
        flash[:error] = "#{I18n.t('activerecord.attributes.base_user.joined_at')}の終了日が正しくありません。"
        redirect_to :action => 'setup', :id => @mlg_magazine.id
        return
      end
      @user_info[:joined_at_end] = joined_at['end(1i)'] + '-' + joined_at['end(2i)'] + '-' + joined_at['end(3i)'] 
    end
    
    # プロフィール情報
    @profile_info = Hash.new
    @profile_info[:sex] = params[:sex].keys unless params[:sex].nil?
    @profile_info[:area] = params[:area].keys unless params[:area].nil?
    @profile_info[:civil_status] = params[:civil_status].keys unless params[:civil_status].nil?
    @profile_info[:age_start] = params[:age][:start].to_i unless params[:age][:start].blank?
    @profile_info[:age_end] = params[:age][:end].to_i unless params[:age][:end].blank?
    
    # ポイント情報
    @point_info = HashWithIndifferentAccess.new
    if !params[:point][:start_point].blank? || !params[:point][:end_point].blank?
      @point_info[:pnt_master_id] = @pnt_master.id
      params[:point].each_pair { |key, value|
        begin
          next if value.blank?
          
          Integer(value)
          @point_info[key] = value
        rescue
          flash[:error] = "#{I18n.t('view.noun.pnt_point')}には整数を入力してください。"
          redirect_to :action => 'setup', :id => @mlg_magazine.id
          return
        end
      }
    end
    
    @user_count = BaseUser.find_users_by_all_search_info(@user_info, @profile_info, @point_info, {}, true)
  end
  
  # 更新処理
  def update
    mlg_magazine = MlgMagazine.find(params[:mlg_magazine][:id])
    mlg_magazine.update_attributes(params[:mlg_magazine])
    
    request_params = Hash.new
    request_params[:mlg_magazine_id] = mlg_magazine.id
    
    # ユーザ情報
    user_info = Hash.new
    user_info[:receive_mail_magazine_flag] = [true] if params[:receive_mail_magazine_flag]
    user_info[:base_carrier_id] = params[:base_carrier_id] unless params[:base_carrier_id].nil?
    unless params[:joined_at].nil?
      user_info[:joined_at_start] = params[:joined_at][:start] unless params[:joined_at][:start].nil?
      user_info[:joined_at_end] =  params[:joined_at][:end] unless params[:joined_at][:end].nil?
    end
    request_params[:user_info] = user_info
    
    # プロフィール情報
    profile_info = Hash.new
    profile_info[:sex] = params[:sex] unless params[:sex].nil?
    profile_info[:civil_status] = params[:civil_status] unless params[:civil_status].nil?
    profile_info[:area] = params[:area] unless params[:area].nil?
    unless params[:age].nil?
      profile_info[:age_start] = params[:age][:start].to_i unless params[:age][:start].blank?
      profile_info[:age_end] = params[:age][:end].to_i unless params[:age][:end].blank?
    end
    request_params[:profile_info] = profile_info
    
    # ポイント情報
    point_info = Hash.new
    unless params[:point].blank?
      point_info[:pnt_master_id] = params[:point][:pnt_master_id]
      point_info[:start_point] = params[:point][:start_point]
      point_info[:end_point] = params[:point][:end_point]
    end
    request_params[:point_info] = point_info
    
    MiddleMan.worker(:mlg_add_target_users_worker).regist_delivery(:args => request_params) unless RAILS_ENV == 'test'
    
    flash[:notice] = '配信設定を行いました。'
    redirect_to :controller => :mlg, :action => :list
  end
  
private
  
  def provide_setup_show
    @pnt_masters = PntMaster.find(:all)
    @carriers = BaseCarrier.find(:all)
  end
    
end
