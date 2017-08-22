# frozen_string_literal: true

namespace :setup do
  desc 'Sets up yml files for Travis CI'
  task :travis do
    def write_file(file, content)
      File.open(file, 'w+') do |f|
        f.write content
      end
    end

    def delete_files(filenames = [])
      filenames.each do |file|
        FileUtils.rm(file) if File.exist?(file)
      end
    end

    def config_default_options
      <<~HEREDOC
        test:
          adapter: sqlite3
          database: ":memory:"
          timeout: 500
      HEREDOC
    end

    def config_default_secrets(secret)
      <<~HEREDOC
        test:
          secret_key_base: #{secret}
          salt: 1
          secret_token:  #{secret}
          devise_secret_key:  #{secret}
      HEREDOC
    end

    secret = `rake secret`
    # delete_files ["config/database.yaml"]
    # `export JRUBY_OPTS="-Xcext.enabled=true"`

    #   write_file "config/database.yml",
    #   'test:
    # adapter: sqlite3
    # database: ":memory:"
    # timeout: 500'
    #   write_file "config/secrets.yml",
    # "test:
    # secret_key_base: #{secret}
    # salt: 1
    # secret_token:  #{secret}
    # devise_secret_key:  #{secret}"

    write_file 'config/database.yml', config_default_options
    write_file 'config/secrets.yml', config_default_secrets(secret)
  end

  desc 'Sets up the secret files after a git clone.'
  task :secret_files do
    def edit(file, line_old, line_changed)
      old_content = File.read(file)
      if old_content[line_old]
        new_content = old_content.gsub(line_old, line_changed)
        File.open(file, 'w+') do |f|
          f.write new_content
        end
      end
    end

    def copy(filename, filename2)
      fail "Could not locate #{filename}." unless File.exist? filename
      fail "File #{filename2} already exists." if File.exist? filename2
      FileUtils.cp filename, filename2
    end

    def secret_key
      secret = `rake secret`
      fail unless $CHILD_STATUS.exitstatus.zero?
      puts secret
      secret.chomp
    end

    copy 'config/database.yml.txt', 'config/database.yml'
    copy 'config/secrets.yml.txt',  'config/secrets.yml'

    def config_secrets_yml
      <<~HEREDOC
        development:
          secret_key_base:
          salt:

        test:
          secret_key_base:
          salt:
      HEREDOC
    end

    def new_config_secrets_yml(secret_key)
      <<~HEREDOC
        development:
          secret_key_base: #{secret_key}
          salt: #{rand 9}
          secret_token: #{rand 9}
          devise_secret_key: #{secret_key}

        test:
          secret_key_base: #{secret_key}
          salt: #{rand 9}
          secret_token: #{rand 9}
          devise_secret_key: #{secret_key}
      HEREDOC
    end

    def production_config_secrets_yml
      <<~HEREDOC
        production:
          secret_key_base: <%= ENV[\"SECRET_KEY_BASE\"] %>
          salt: 192
      HEREDOC
    end

    def production_new_config_secrets_yml(secret_key)
      <<~HEREDOC
        production:
          secret_key_base: #{secret_key}
          salt: #{rand 9}
      HEREDOC
    end

    edit 'config/secrets.yml', config_secrets_yml, new_config_secrets_yml(secret_key)
    edit 'config/secrets.yml',
         production_config_secrets_yml, production_new_config_secrets_yml(secret_key)

    #     edit "config/secrets.yml",
    # "development:
    #   secret_key_base:
    #   salt:
    #
    # test:
    #   secret_key_base:
    #   salt:
    # ",
    # "development:
    #   secret_key_base: #{secret_key}
    #   salt: #{rand 9}
    #   secret_token: #{rand 9}
    #   devise_secret_key: #{secret_key}
    #
    # test:
    #   secret_key_base: #{secret_key}
    #   salt: #{rand 9}
    #   secret_token: #{rand 9}
    #   devise_secret_key: #{secret_key}
    # "
    #     edit "config/secrets.yml",
    # "production:
    #   secret_key_base: <%= ENV[\"SECRET_KEY_BASE\"] %>
    #   salt: 192",
    # "production:
    #   secret_key_base: #{secret_key}
    #  salt: #{rand 9}"
  end
end
