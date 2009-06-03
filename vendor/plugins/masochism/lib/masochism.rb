require 'rake'

namespace :db do
  task :create => :environment do
    create_database(ActiveRecord::Base.configurations[RAILS_ENV]["master_database"])
  end
end

require 'active_reload/connection_proxy'
require 'active_reload/master_filter'

#ActiveReload::ConnectionProxy.setup!