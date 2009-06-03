module ManageBaseDevicesControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def show
    @jpmobile_device = Jpmobile::Model::JpmobileDevice.find(params[:id])
  end

  def available_confirm
    @jpmobile_device = Jpmobile::Model::JpmobileDevice.find(params[:id])
  end
  
  def available
    @jpmobile_device = Jpmobile::Model::JpmobileDevice.find(params[:id])
    
    if cancel?
      redirect_to manage_base_device_path(@jpmobile_device)
      return
    end
    
    @jpmobile_device.available_flag = true
    if @jpmobile_device.save
      flash[:notice] = "#{@jpmobile_device.name}を有効にしました。"
      redirect_to manage_base_device_path(@jpmobile_device)
    else
      flash[:notice] = "#{@jpmobile_carrier.name}を有効にできませんでした。"
      render :action => 'available_confirm'
    end
  end
  
  def unavailable_confirm
    @jpmobile_device = Jpmobile::Model::JpmobileDevice.find(params[:id])
  end
  
  def unavailable
    @jpmobile_device = Jpmobile::Model::JpmobileDevice.find(params[:id])
    
    if cancel?
      redirect_to manage_base_device_path(@jpmobile_device)
      return
    end
    
    @jpmobile_device.available_flag = false
    if @jpmobile_device.save
      flash[:notice] = "#{@jpmobile_device.name}を無効にしました。"
      redirect_to manage_base_device_path(@jpmobile_device)
    else
      flash[:notice] = "#{@jpmobile_device.name}を無効にできませんでした。"
      render :action => 'unavailable_confirm'
    end
  end
    
end

