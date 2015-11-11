source 'https://rubygems.org'
server = ['sql', 'mysql', 'heroku', 'sqlite'][2] #remember to change config/database.yml

#ruby=jruby-9.0.3.0
# ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.22'
ruby '2.2.2', :engine => 'jruby', :engine_version => '9.0.3.0'

# gem 'jruby-jars', '1.7.22' #Now explicitly calling jruby-jars version
gem 'jruby-jars', '9.0.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'

platforms :jruby do
  group :development do
    gem 'activerecord-jdbcsqlite3-adapter'
  end
  group :production do
    #ProcfileHeroku: web: bundle exec rails server puma -p $PORT -e $RACK_ENV
    case server
    when 'heroku'
      gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.18'
    when 'sql'
      gem 'activerecord-jdbcmssql-adapter', '~> 1.3.18'
    when 'mysql', 'mariadb'
      gem 'activerecord-jdbcmysql-adapter', '~> 1.3.18'
    end
  end
  gem 'activerecord-jdbc-adapter', '~> 1.3.18'
  gem 'therubyrhino'               # JavaScript library
end

# Puma as server
gem 'puma', '~> 2.13.4'

# For CSV importing and exporting
gem 'smarter_csv' #, '~> 1.0.19' #1.0.19 is out...
gem 'cmess', require: false #, '~> 0.4.1'
gem 'celluloid', '~> 0.17.1.2', require: false

# Use SCSS for stylesheets
gem 'sass-rails'##, '~> 4.0.3' #5.0.4
gem 'bootstrap-sass'#, '~> 3.2.0.2' # is available 3.3.5.1
gem 'haml-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0.5'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# Turbo links also affect native load bars in web-browsers
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.3.1'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0',                              group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt'##, '~> 3.1.10'
gem 'devise'##, '~> 3.5.2'

# Use unicorn as the app server
# gem 'unicorn'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Time Zone info data (for Rails 4.1)
gem 'tzinfo-data'

# Markdown
gem 'kramdown', '~> 1.8.0'

# Pagination
gem 'will_paginate'#, '~> 3.0.7' #.7 out now
gem 'bootstrap-will_paginate'

# Console
gem 'pry'

## Used #gem 'magic_comment' to add encoding to all files ##
group :development do
  # gem 'localeapp', require: false
  # gem 'guard-rspec', '~> 4.2.8'
  # gem 'guard-spork', '~> 1.5.1' #Some Problem with Spork and rails 4.2
  # gem 'spork-rails', github: 'sporkrb/spork-rails'
  # gem 'rb-fsevent', '~> 0.9.3'
end

group :development, :test do
  # RSpec
  gem 'rspec'#, '~> 2.99.0'
  gem 'rspec-rails'#, '~> 2.99.0'
  gem 'factory_girl_rails'#, '~> 4.2.1'
  # Guard
  gem 'guard-jruby-rspec', require: false, platform: :jruby
  # gem 'rb-fsevent' if `uname` =~ /Darwin/
end

group :test do
  # Capybara (Integration Tests)
  gem 'faker'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy', require: false
end

platforms :ruby do
  group :development do
    gem 'sqlite3'
    gem 'github-pages', require: false  # Jekyll Integration
  end
  group :production do
    gem 'therubyracer'    # JavaScript library
    gem 'pg'              # Heroku db (PostgresQL)
    gem 'unicorn'         # Use unicorn as the app server
    gem 'rails_12factor'  # 12 Factor App for Log Stream & Serving Static files - Scaling
  end
end

group :deploy do
  platforms :jruby do
    # For Warbler changes to config/application.rb and config/environtments/production.rb
    # gem 'warbler', '1.4.7', require: false
    # github: 'rebelwarrior/warbler'
    gem 'warbler', require: false, github: 'jruby/warbler', branch: '2.x-dev'
    # Warbler doesn't support jruby-9k yet. Pulling from dev repo (or my repo).
  end
end
