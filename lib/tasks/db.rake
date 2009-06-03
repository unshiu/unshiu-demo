require 'yaml/encoding'
require 'active_record/fixtures'

namespace :db do
  
  desc "load data to database from db/data"
  task :load => :environment do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    if ENV['FIXTURES']
      files = ENV['FIXTURES'].split(/,/)
    else
      files = Dir.glob(File.join(RAILS_ROOT, 'db', 'data', '*.{yml,csv}'))
    end
    files.each { |fixture_file| Fixtures.create_fixtures('db/data', File.basename(fixture_file, '.*'))}
  end

end