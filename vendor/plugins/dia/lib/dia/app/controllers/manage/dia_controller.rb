module ManageDiaControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
    redirect_to :controller => 'dia_entry', :action => 'list'
  end
end
