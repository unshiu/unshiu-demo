module ManageMngSystemControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
   
  def index
    @system = MngSystem.new
  end
  
  def mail
  end
  
  def database
    @db_adapter = ActiveRecord::Base.connection.adapter_name 
    @system = MngSystem.new
  end
  
  def cache
    @system = MngSystem.new
  end
  
  def check
    @system = MngSystem.new
  end
  
end
