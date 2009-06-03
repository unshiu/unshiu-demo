module ManageBaseMobilesControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    @jpmobile_carriers = Jpmobile::Model::JpmobileCarrier.find(:all)
    @mobiles_news = Array.new
  end
      
  def search
    device_name = "%" + params[:keyword] + "%"
    @jpmobile_devices = Jpmobile::Model::JpmobileDevice.find(:all, :order => 'id asc',
                                                             :conditions => ['name like ?', device_name],
                                                             :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})    
  end
  
end
