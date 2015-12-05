# As suggested on:
# deployingjruby.blogspot.com/2014/12/using-puma-with-rails-4-on-heroku.html

Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveRecord.on_load(:active_record) do
    config = ActiveRecord::Base.configuration[Rails.env] ||
      Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['MAX_PUMA_THREADS'] || 16
    ActiveRecord::Base.establish_connection(config)
  end
end
