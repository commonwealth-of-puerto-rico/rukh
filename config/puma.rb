# for Heroku
# workers Integer(ENV['WEB_CONCURRENCY'] || 2) # Remove for JRuby
threads_count = Integer(ENV['MAX-THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']      || 3000
environment ENV['RACK_ENV']  || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See heroku documentation
  ActiveRecord::Base.establish_connection
end
