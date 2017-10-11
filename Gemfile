source 'https://rubygems.org'
server = ['sql', 'mysql', 'heroku', 'sqlite'][3] #remember to change config/database.yml

#ruby=jruby-9.1.13.0
ruby '2.3.3', :engine => 'jruby',
  :engine_version => '9.1.13.0'
gem 'jruby-jars', '9.1.13.0' #Now explicitly calling jruby-jars version

gem 'rails', '~> 4.2.10' 

platforms :jruby do
  group :development,:test do
    gem 'activerecord-jdbcsqlite3-adapter'
  end
  group :production do
    #ProcfileHeroku: web: bundle exec rails server puma -p $PORT -e $RACK_ENV
    case server
    when 'heroku', 'postgresql'
      gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.20' #TODO pull rails 5 version off github
    when 'sql'
      gem 'activerecord-jdbcmssql-adapter', '~> 1.3.20'
    when 'mysql', 'mariadb'
      gem 'activerecord-jdbcmysql-adapter', '~> 1.3.20'
    # when 'sqlite'
      # gem 'activerecord-jdbcsqlite3-adapter' 
    end
  end
  gem 'activerecord-jdbc-adapter', '~> 1.3.20'
  gem 'therubyrhino'  # JavaScript library
end

# Puma as server
gem 'puma'

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'bootstrap-sass'
gem 'haml'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'  , '~> 4.2' #'~> 4.1.0'

# Use jquery as the JavaScript library jquery-ui as the widget library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0.5'

# Turbolinks makes following links in your web application faster. 
# Read more: https://github.com/rails/turbolinks
# Turbo links also affect native load bars in web-browsers
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'#, '~> 2.4.1'

# Use ActiveModel has_secure_password
gem 'bcrypt'##, '~> 3.1.10'
gem 'devise'##, '~> 3.5.6'

# Time Zone info data (for Rails 4.1)
gem 'tzinfo-data', '1.2016.10', platforms: :jruby

# Markdown
gem 'kramdown', '>= 1.10.0' 

# Pagination
gem 'will_paginate'#, '~> 3.0.7' 
gem 'bootstrap-will_paginate'

# Excel output
gem 'rubyzip', '~> 1.2.1'
gem 'axlsx', git: 'https://github.com/randym/axlsx', branch: 'master'
gem 'axlsx_rails'

# Excel importing
gem 'roo'

# For CSV importing and exporting
gem 'smarter_csv', require: false #, '~> 1.0.19' #1.0.19 is out...
gem 'cmess', require: false #, '~> 0.4.1'
gem 'celluloid', '~> 0.17.3', require: false
gem 'sucker_punch', require: false 

# Console
gem 'pry'

# 12 Factor App for Log Stream & Serving Static files - Scaling
gem 'rails_12factor'

## Used #gem 'magic_comment' to add encoding to all files for Windows ##

group :development, :test do
  # For Travis CI
  gem 'rake'
  # RSpec
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  # Guard
  gem 'guard-jruby-rspec', require: false, platform: :jruby
  # Rubocop (Style-guide and linter)
  gem 'rubocop', '~> 0.49.1', require: false 
  gem 'rubocop-rspec', require: false
  # Breakman (Static Code Analysis)
  gem 'brakeman', :require => false
end

group :test do
  # Capybara (Integration Tests)
  gem 'faker'
  gem 'capybara'
  gem 'launchy', require: false
end

group :deploy do
  platforms :jruby do
    # For Warbler see: config/application.rb and config/environtments/production.rb
    gem 'warbler', '>= 2.0.4', require: false
  end
end

