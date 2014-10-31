source 'https://rubygems.org'
server = ['sql', 'mysql', 'heroku'][0] #remember to change db.yml

#ruby=jruby-1.7.16.1
ruby '2.0.0', :engine => 'jruby', :engine_version => '1.7.16.1' 
gem 'jruby-jars', '1.7.16.1' #Now explicitly calling jruby-jars version


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.7'
# Devise breaks in 4.2.beta at the moment.

platforms :jruby do
  group :development do
    gem 'activerecord-jdbcsqlite3-adapter'
  end
  group :production do
    #Procfileheroku: web: bundle exec rails server puma -p $PORT -e $RACK_ENV
    case server
    when 'heroku' 
      gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.10' #1.3.10 is out
    when 'sql'
      gem 'activerecord-jdbcmssql-adapter', '~> 1.3.10'
    when 'mysql'
      gem 'activerecord-jdbcmysql-adapter', '~> 1.3.10'
    end
  end 
  gem 'activerecord-jdbc-adapter', '~> 1.3.10' 
  gem 'therubyrhino' #JavaScript library
end

# Puma as server
gem 'puma', '~> 2.9.2' 

# For CSV importing
gem 'smarter_csv', '~> 1.0.17'
gem 'cmess', '~> 0.4.1'

# Use SCSS for stylesheets
gem 'sass-rails'#, '~> 4.0.3'
gem 'bootstrap-sass', '~> 3.2.0.0' #'~> 3.1.1.1' #'~> 2.3.2.2' #'~> 3.2.0.0' is available
gem 'haml-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.1'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2.1' #'5.0.0' has an error

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0',                              group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'devise', '~> 3.2.4'

# Use unicorn as the app server
# gem 'unicorn'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Time Zone info data (for Rails 4.1)
gem 'tzinfo-data'

# Markdown
gem 'kramdown' 

# Pagination
gem 'will_paginate', '~> 3.0.7' #.7 out now
gem 'bootstrap-will_paginate'

# Console
gem 'pry'


group :development do
  # gem 'localeapp', require: false
  gem 'guard-rspec', '~> 4.2.8'
  gem 'guard-spork', '~> 1.5.1'
  # gem 'spork-rails', github: 'sporkrb/spork-rails'
  gem 'rb-fsevent', '~> 0.9.3'
end

group :development, :test do
  # RSpec
  gem 'rspec', '~> 2.99.0' 
  gem 'rspec-rails', '~> 2.99.0' 
  gem 'factory_girl_rails', '~> 4.2.1'
end

group :test do
  gem 'faker'
  gem 'capybara', '~> 2.2.1' #For Rspec3 (consider removing version)
  gem 'database_cleaner'
  gem 'launchy', require: false
  # gem 'email_spec', '>= 1.6.0'
end

platforms :ruby do
  group :development do
    gem 'sqlite3'
    gem 'github-pages', require: false  # Jekyll Integration
  end
  group :production do
    gem 'therubyracer'    # JavaScript library
    gem 'pg'              # heroku db
    gem 'unicorn'         # Use unicorn as the app server
    gem 'rails_12factor'  # 12 Factor App for Log Stream & Serving Static files - Scaling
  end
end

group :deploy do
  platforms :jruby do
    # For Warbler changes to config/application.rb and config/environtments/production.rb
    gem 'warbler', '1.4.4', :require => false # 1.4.4 is out
  end
end

