module ManageBasePluginsControllerModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  def index
  end
  
  def show
    @plugin = params[:id]
    @plugin_info = Rails::Plugin.new("vendor/plugins/#{params[:id]}").about
    @plugin_news = BasePlugin.news_by_name(@plugin)
  end
  
  def news
    @plugin_news = BasePlugin.news
  end
  
end