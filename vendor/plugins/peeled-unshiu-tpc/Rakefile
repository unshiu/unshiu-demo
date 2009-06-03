require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'version'

PKG_NAME      = 'tpc'
PKG_VERSION   = Tpc::VERSION::STRING
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the tpc plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the tpc plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Tpc'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

$: << "../../../"
desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext/utils'
  GetText::ActiveRecordParser.init(:db_yml => "../../../config/database.yml")
  
  ENV["MSGMERGE_PATH"] = "msgmerge --sort-output --no-fuzzy-matching"
  GetText.update_pofiles("#{PKG_NAME}", 
                         Dir.glob("{app,lib,generators}/**/*.{rb,rhtml}"),
                         "#{PKG_NAME} #{PKG_VERSION}")
end

desc "setup pot/po/mo files to plugin generate."
task :setuppo do
  FileUtils.cp("po/#{PKG_NAME}.pot",   "generators/#{PKG_NAME}/templates/po/#{PKG_NAME}.pot")
  FileUtils.cp("po/ja/#{PKG_NAME}.po", "generators/#{PKG_NAME}/templates/po/ja/#{PKG_NAME}.po")
  FileUtils.cp("po/ja/#{PKG_NAME}.mo", "generators/#{PKG_NAME}/templates/locale/ja/LC_MESSAGES/#{PKG_NAME}.mo")
end