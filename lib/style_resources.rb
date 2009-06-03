require 'singleton'
require 'yaml'

# StyleResources[key] でアクセス可能
# 読み込むファイル名を RESOURCE_FILES に追加する必要がある
class StyleResources
  include Singleton
  # 読み込むファイル名の一覧
  RESOURCE_FILES = ["style"]
  
  # resource file name
  RESOURCE_FILE_PREFIX = "#{RAILS_ROOT}/config/"
  RESOURCE_FILE_SUFFIX = ".yml"
 
  # usage: StyleResources["key_name"]
  def self.[](key)
    self.instance[key]
  end
  
  # usage: StyleResources.instance["key_name"]
  def [](key)
    load if @style_resources == nil
    @style_resources[key]
  end

  # usage: StyleResources.instance.load
  def load
    @style_resources = Hash.new
    for file in RESOURCE_FILES
      @style_resources.merge!(YAML.load_file(RESOURCE_FILE_PREFIX + file + RESOURCE_FILE_SUFFIX))
    end
  end
end