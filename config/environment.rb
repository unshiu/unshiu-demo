# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'string_expanse'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Add new inflection rules using the following format
  # (all these examples are active by default):
  # Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
  # end
  # See Rails::Configuration for more options
 
  config.gem "mysql",              :version => "2.7"
  config.gem "rmagick",            :version => "~> 2.5.0", :lib => 'RMagick'           
  config.gem "ar-extensions",      :version => "~> 0.8.2",   :install_options => "--ignore-dependencies"
  config.gem "capistrano",         :version => "~> 2.5"
  config.gem "fastercsv",          :version => "~> 1.2.3"
  config.gem "json",               :version => "~> 1.1.2"
  config.gem "acts_as_searchable", :version => "~> 0.1.0"
  config.gem "mongrel",            :version => "~> 1.1.5"
  config.gem "mongrel_cluster",    :version => "~> 1.0.5", :lib => "mongrel_cluster/init"
  config.gem "memcache-client",    :version => "~> 1.5.0", :lib => 'memcache'
  config.gem "uuidtools",          :version => "~> 1.0"
  config.gem "launchy",            :version => "~> 0.3"
  config.gem "ci_reporter",        :version => "~> 1.5",   :lib => "ci/reporter/core"
  config.gem "mocha",              :version => "~> 0.9"
  config.gem "packet",             :version => "~> 0.1"
  config.gem "chronic",            :version => "~> 0.2"
  #config.gem "tsukasaoishi-miyazakiresistance", :version => "~> 0.1.2", :lib => "MiyazakiResistance"
  config.gem "locale",             :version => "~> 2.0.1"
  config.gem "locale_rails",       :version => "~> 2.0.1"
  
  config.after_initialize do
    unless Rails.env.test?
      ActiveReload::ConnectionProxy::setup!
    end
  end
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

