desc "Add schema information (as comments) to model files non schema number"
task :annotate_models do
   require File.join(File.dirname(__FILE__), "../../vendor/plugins/annotate_models/lib/annotate_models.rb")
   require File.join(File.dirname(__FILE__), "../annotate_models_expanse.rb")
   AnnotateModels.do_annotations
end

namespace :peeled_unshiu do
  
  namespace :plugins do
    require 'unshiu/plugins'
    
    desc 'all plugin generate.'
    task :generate do 
      Unshiu::Plugins::LIST.each do |plugin|
        system "yes | ruby script/generate #{plugin} #{plugin}"
      end
    end
    
    desc 'all plugin migrate generate.'
    task :migrate_generate do 
      Unshiu::Plugins::LIST.each do |plugin|
        system "ruby script/generate plugin_migration #{plugin} "
      end
    end
    
    desc 'all plugin template generate.'
    task :template_generate do 
      Unshiu::Plugins::LIST.each do |plugin|
        system "ruby script/generate unshiu_plugin_template_generator #{plugin}"
      end
    end
    
    desc 'all　unshiu plugin trunk install.'
    task :install_plugin_trunk_all, "user"
    task :install_plugin_trunk_all do |task, args|
      task.set_arg_names ["user"]
      Unshiu::Plugins::EXTERNAL_LIST.each do |plugin|
        system "rm -rf vendor/plugins/#{plugin}" if File.exist?("vendor/plugins/#{plugin}")
        system "ruby script/install git://github.com/unshiu/peeled-unshiu-#{plugin}.git"
      end
    end
    
    desc "Report code statistics (KLOCs, etc) from the plugin "
    task :stats, "plugin_name"
    task :stats do |task, args|
      task.set_arg_names ["plugin_name"]
      require 'code_statistics'
      STATS_DIRECTORIES = [
        ["Controllers",        "lib/#{args.plugin_name}/app/controllers"],
        ["Helpers",            "lib/#{args.plugin_name}/app/helpers"], 
        ["Models",             "lib/#{args.plugin_name}/app/models"],
        ["Libraries",          "lib/"],
        ["Integration\ tests", "test/integration"],
        ["Functional\ tests",  "test/functional"],
        ["Unit\ tests",        "test/unit"]
      ].collect { |name, dir| [ name, "#{RAILS_ROOT}/vendor/plugins/#{args.plugin_name}/#{dir}" ] }.select { |name, dir| File.directory?(dir) }
      CodeStatistics.new(*STATS_DIRECTORIES).to_s
    end
    
    desc "Add schema information (as comments) to model files for plugin"
      task :annotate_models, "plugin_name"
      task :annotate_models do |task, args|
        task.set_arg_names ["plugin_name"]

        require File.join(File.dirname(__FILE__), "../../vendor/plugins/annotate_models/lib/annotate_models.rb")
        require File.join(File.dirname(__FILE__), "../annotate_models_expanse.rb")
        AnnotateModels.do_plugin_annotations(args.plugin_name)
    end
    
    desc "Add schema information (as comments) to model files for all plugin"
      task :annotate_models_all do 
        require File.join(File.dirname(__FILE__), "../../vendor/plugins/annotate_models/lib/annotate_models.rb")
        require File.join(File.dirname(__FILE__), "../annotate_models_expanse.rb")
        
        Unshiu::Plugins::LIST.each do |plugin|
          AnnotateModels.do_plugin_annotations(plugin)
        end
    end
    
  end
  
  desc "Add schema information (as comments) to model files"
  task :annotate_models do
    require File.join(File.dirname(__FILE__), "../../vendor/plugins/annotate_models/lib/annotate_models.rb")
    require File.join(File.dirname(__FILE__), "../annotate_models_expanse.rb")
    AnnotateModels.do_annotations
  end
 
end