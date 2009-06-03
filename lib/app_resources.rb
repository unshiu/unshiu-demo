require 'singleton'
require 'yaml'

# AppResources[key] でアクセス可能
# ファイルは config/unshiu 下におかれたものが自動的にロードされる
class AppResources
  include Singleton
  
  # resource file path
  RESOURCE_FILE_PREFIX = "#{RAILS_ROOT}/config/unshiu/"  

  # usage: AppResources["key_name"]
  def self.[](key)
    self.instance[key]
  end
  
  # リソース情報を取得する
  # usage: AppResources.instance["key_name"]
  def [](key)
    load if @app_resources == nil
    @app_resources[key]
  end
  
  # リソース情報をロードする
  # usage: AppResources.instance.load
  def load
    @app_resources = HashWithIndifferentAccess.new
    Dir::glob(RESOURCE_FILE_PREFIX + '*.yml').each do |file_path|
      filename = File.basename(file_path, ".*")
      @app_resources[filename] = YAML.load_file(file_path)[RAILS_ENV]
    end
  end
  
end