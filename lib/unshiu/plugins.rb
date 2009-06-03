module Unshiu
  module Plugins
    
    # plugin の有無を確認する
    # ex) 
    #  Unshiu::Plugins.base? # 存在の有無を返す
    #  Unshiu::Plugins.active_base? # 有効かどうか（generate済み）を返す
    def self.method_missing(name, *args)
      name = name.to_s.scan(/[0-9A-Za-z]+\\?/)
      false if name.empty? || name.size > 2
      
      if name.size == 1
        File.directory?("#{RAILS_ROOT}/vendor/plugins/#{name[0]}") ? true : false
      else
        case name[0]
        when "active"
          File.exist?("#{RAILS_ROOT}/config/unshiu/#{name[1]}.yml") ? true : false
        else
        end
      end
      
    end
    
    # unshiu plugin リスト
    LIST = ['base', 'abm', 'dia', 'prf', 'msg', 'pnt', 'cmm', 'mlg', 'mng', 'tpc', 'ace', 'mixi']
    
    # 現在有効なplugin
    ACTIVE_LIST = LIST.clone.delete_if { |plugin| eval("!active_#{plugin}?") }
    
    # 外部　plugin リスト
    EXTERNAL_LIST = ['jpmobile', 'acts_as_paranoid', 'auto_nested_layouts', 'file_column', 'paginating_find']
    
  end
end
