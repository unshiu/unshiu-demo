# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Unshiu::ApplicationControllerModule
  
  if Unshiu::Plugins.active_base?
    include BaseApplicationControllerModule
  end
  
  if Unshiu::Plugins.active_pnt? # for pnt plugin
    include PntPointSystem
    around_filter :pnt_target_filter
  end
end
