#
# AnnotateModels
module AnnotateModels
  
  def self.annotate_one_file(file_name, info_block)
    if File.exist?(file_name)
      content = File.read(file_name)

      # Remove old schema info
      content.sub!(/^# #{PREFIX}.*?\n(#.*\n)*\n/, '')
      
      # 改行コードを Unix に合わせるため \r\n を \n に変換 
      content.gsub!(/\r\n/, '\n')

      # バイナリモードで出力
      File.open(file_name, "wb") { |f| f.puts info_block + content }
    end
  end

  # unshiuプラグイン用のannotation作成を実行する
  # 対象をプラグインlibのmodelにしているだけで挙動はdo_annotationsと同様
  # _param1_:: unshiuプラグイン名
  def self.do_plugin_annotations(plugin_name)
    plugin_path = File.join(RAILS_ROOT, "vendor/plugins/#{plugin_name}/lib/#{plugin_name}/app/models")
    
    header = PREFIX.dup
    
    self.get_model_names.each do |m|
      class_name = m.sub(/\.rb$/,'').camelize
      begin
        klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) }
        if klass < ActiveRecord::Base && !klass.abstract_class?
          puts "Annotating #{class_name}"
          self.plugin_annotations(plugin_path, klass, header)
        else
          puts "Skipping #{class_name}"
        end
      rescue Exception => e
        puts "Unable to annotate #{class_name}: #{e.message}"
      end
      
    end
  end
  
  def self.plugin_annotations(path, klass, header)
    info = get_schema_info(klass, header)
    
    model_file_name = File.join(path, klass.name.underscore + ".rb")
    annotate_one_file(model_file_name, info)
  end
  
end
