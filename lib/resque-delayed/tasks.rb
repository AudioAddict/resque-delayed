require 'resque-delayed'

# require 'resque-delayed/tasks'
namespace :resque_delayed do

  desc "Start a Resque::Delayed worker"
  task :work do
    unless Resque.redis.instance_variable_get(:@redis).zcard("").zero?
      STDERR.puts %Q{
WARNING: you have a sorted set stored at the empty string key in your redis instance
if you've just upgraded from Resque::Delayed 1.0.0 you probably want to run

 $ bundle exec rake resque_delayed:migrate_queue key

see resque-delayed/CHANGELOG.md for details}
    end

    begin
      worker = Resque::Delayed::Worker.new
      worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
      worker.very_verbose = ENV['VVERBOSE']
    end

    if ENV['PIDFILE']
      File.open(ENV['PIDFILE'], 'w') { |f| f << worker.pid }
    end

    worker.log "Starting Resque::Delayed worker #{worker}"

    worker.work(ENV['INTERVAL'] || 5) # interval, will block
  end
end
