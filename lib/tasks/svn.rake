namespace :svn do
  desc 'Commit to the repository safely.'
  task :commit => [
    :up,
    :'db:migrate',
    :annotate_models,
    :test,
    :'test:plugins',
  ] do
    if msg = ENV['M']
      msg.gsub!(/\"/, '\"')
      system %Q{svn ci #{RAILS_ROOT} -m "#{msg}"}
    else
      system "svn ci #{ARGV[-1..2]}"
    end
  end

  desc 'Update working copy.'
  task :up do
    system "svn up #{RAILS_ROOT}"
  end
end

