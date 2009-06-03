module ManageBaseCarriersControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def show
    @jpmobile_carrier = Jpmobile::Model::JpmobileCarrier.find(params[:id])
    @jpmobile_devices = Jpmobile::Model::JpmobileDevice.find(:all, :order => 'id asc',
                                                             :conditions => ['jpmobile_carrier_id = ?', params[:id]],
                                                             :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
  end
    
  def available_confirm
    @jpmobile_carrier = Jpmobile::Model::JpmobileCarrier.find(params[:id])
  end
  
  def available
    @jpmobile_carrier = Jpmobile::Model::JpmobileCarrier.find(params[:id])
    
    if cancel?
      redirect_to manage_base_carrier_path(@jpmobile_carrier)
      return
    end
    
    @jpmobile_carrier.available_flag = true
    if @jpmobile_carrier.save
      flash[:notice] = "#{@jpmobile_carrier.name}を有効にしました。"
      redirect_to manage_base_carrier_path(@jpmobile_carrier)
    else
      flash[:notice] = "#{@jpmobile_carrier.name}を有効にできませんでした。"
      render :action => 'available_confirm'
    end
  end
  
  def unavailable_confirm
    @jpmobile_carrier = Jpmobile::Model::JpmobileCarrier.find(params[:id])
  end
  
  def unavailable
    @jpmobile_carrier = Jpmobile::Model::JpmobileCarrier.find(params[:id])
    
    if cancel?
      redirect_to manage_base_carrier_path(@jpmobile_carrier)
      return
    end
    
    @jpmobile_carrier.available_flag = false
    if @jpmobile_carrier.save
      flash[:notice] = "#{@jpmobile_carrier.name}を無効にしました。"
      redirect_to manage_base_carrier_path(@jpmobile_carrier)
    else
      flash[:notice] = "#{@jpmobile_carrier.name}を無効にできませんでした。"
      render :action => 'unavailable_confirm'
    end
  end
  
end
