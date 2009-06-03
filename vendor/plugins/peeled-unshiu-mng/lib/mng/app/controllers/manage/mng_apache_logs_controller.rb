module ManageMngApacheLogsControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    @mng_apache_logs = MngApacheLog.find_all
  end

  def download
    path = "#{AppResources[:mng][:apache_log_dir]}/#{params[:id]}"
    send_file path, :filename => params[:id]
  end
  
end