# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Unshiu::ApplicationHelperModule
  
  if Unshiu::Plugins.active_base?
    include BaseHelper
  end
  
  if Unshiu::Plugins.active_cmm?
    include CmmHelper
  end
  
  if Unshiu::Plugins.active_abm?
    include AbmHelper
  end
  
  if Unshiu::Plugins.active_ace?
    include AceHelper
  end
  
end