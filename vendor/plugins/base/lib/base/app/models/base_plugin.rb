require 'open-uri'
require 'rss'

module BasePluginModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
      end
    end
  end
  
  module ClassMethods
    
    # ニュースを取得する
    def news
      result = Array.new
      unless rss.nil?
        rss.items.each do |item| 
          result << item
        end
      end
      result
    end
    
    # 指定pluginのニュースを取得する
    # _param1_:: name プラグイン名
    def news_by_name(name)
      result = Array.new
      unless rss.nil?
        rss.items.each do |item| 
          result << item if item.title =~ /\[release\]\[#{name}\]/
        end
      end
      result
    end
        
  private 
  
    # rss情報を取得するメソッド
    def rss
      open(AppResources[:base][:plugin_news_url]){ |file| RSS::Parser.parse(file.read) }
    rescue => e
      nil
    end
  end
  
end